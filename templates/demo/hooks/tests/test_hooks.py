import json
import os
import shutil
from pathlib import Path
import subprocess
import tempfile
import unittest


HOOKS = Path(__file__).resolve().parents[1]


class HookTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.log = self.root / 'calls'
        self.env = os.environ.copy()
        self.env.update(HOME=str(self.root), XDG_STATE_HOME=str(self.root / 'state'),
                        DEMO_HOOK_PATH=str(self.bin), HOOK_TEST_LOG=str(self.log))
        for name in ('runuser', 'systemctl', 'env', 'timeout', 'sudo'):
            fake = self.bin / name
            fake.write_text('#!/usr/bin/python3\n'
                            'import json, os, sys\n'
                            'with open(os.environ["HOOK_TEST_LOG"], "a") as f:\n'
                            '    f.write(json.dumps([os.path.basename(sys.argv[0]), *sys.argv[1:]]) + "\\n")\n'
                            'if os.environ.get("HOOK_FAIL") == os.path.basename(sys.argv[0]): sys.exit(1)\n'
                            'if os.path.basename(sys.argv[0]) == "timeout": os.execvp(sys.argv[2], sys.argv[2:])\n'
                            'if os.path.basename(sys.argv[0]) == "runuser": os.execvp(sys.argv[4], sys.argv[4:])\n'
                            'if os.path.basename(sys.argv[0]) == "env":\n'
                            '    args = sys.argv[1:]\n'
                            '    while args and "=" in args[0]:\n'
                            '        k, v = args.pop(0).split("=", 1); os.environ[k] = v\n'
                            '    os.execvp(args[0], args)\n')
            fake.chmod(0o755)
        self.env['PATH'] = str(self.bin) + os.pathsep + os.environ.get('PATH', '')

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def template(self, name):
        content = (HOOKS / name).read_text()
        for key, value in {'@USER@': 'testuser', '@HOME@': str(self.root),
                           '@UID@': '1234', '@RUN_ACTIVE@': str(self.bin / 'active')}.items():
            content = content.replace(key, value)
        path = self.root / name
        path.write_text(content)
        path.chmod(0o755)
        return path

    def run_hook(self, path, *args, **env):
        return subprocess.run([str(path), *args], env={**self.env, **env},
                              text=True, capture_output=True, check=False)

    def test_pre_runs_sleep_as_user_with_timeout(self):
        active = self.bin / 'active'
        active.write_text('#!/usr/bin/python3\nimport json, os, sys\nwith open(os.environ["HOOK_TEST_LOG"], "a") as f: f.write(json.dumps(["active", *sys.argv[1:]]) + "\\n")\n')
        active.chmod(0o755)
        result = self.run_hook(self.template('system-sleep'), 'pre')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [
            ['timeout', '70s', 'runuser', '-u', 'testuser', '--', 'env',
             f'HOME={self.root}', 'XDG_RUNTIME_DIR=/run/user/1234', str(active), 'sleep'],
            ['runuser', '-u', 'testuser', '--', 'env', f'HOME={self.root}',
             'XDG_RUNTIME_DIR=/run/user/1234', str(active), 'sleep'],
            ['env', f'HOME={self.root}', 'XDG_RUNTIME_DIR=/run/user/1234', str(active), 'sleep'],
            ['active', 'sleep']])

    def test_post_and_full_connectivity_start_service(self):
        expected = [['systemctl', '--user', '-M', 'testuser@', 'start', '--no-block', 'demo-resume.service']]
        for name, args, env in [('system-sleep', ('post',), {}),
                                ('nm-dispatcher', ('wlan0', 'connectivity-change'), {'CONNECTIVITY_STATE': 'FULL'})]:
            with self.subTest(name=name):
                self.log.unlink(missing_ok=True)
                result = self.run_hook(self.template(name), *args, **env)
                self.assertEqual(result.returncode, 0)
                self.assertEqual(self.calls(), expected)

    def test_other_events_do_nothing(self):
        cases = [('system-sleep', (), {}), ('system-sleep', ('other',), {}),
                 ('nm-dispatcher', ('wlan0', 'up'), {'CONNECTIVITY_STATE': 'FULL'}),
                 ('nm-dispatcher', ('wlan0', 'connectivity-change'), {'CONNECTIVITY_STATE': 'LIMITED'}),
                 ('nm-dispatcher', ('wlan0', 'connectivity-change'), {})]
        for name, args, env in cases:
            with self.subTest(name=name, args=args, env=env):
                self.assertEqual(self.run_hook(self.template(name), *args, **env).returncode, 0)
                self.assertEqual(self.calls(), [])

    def test_failures_do_not_block(self):
        for name, args, env in [('system-sleep', ('pre',), {'HOOK_FAIL': 'timeout'}),
                                ('system-sleep', ('post',), {'HOOK_FAIL': 'systemctl'}),
                                ('nm-dispatcher', ('wlan0', 'connectivity-change'),
                                 {'HOOK_FAIL': 'systemctl', 'CONNECTIVITY_STATE': 'FULL'})]:
            with self.subTest(name=name):
                self.assertEqual(self.run_hook(self.template(name), *args, **env).returncode, 0)

    def test_run_active_no_deck_is_quiet(self):
        active = self.root / 'state/demo/active'
        for value in (None, '', str(self.root / 'missing')):
            with self.subTest(value=value):
                if value is not None:
                    active.parent.mkdir(parents=True, exist_ok=True)
                    active.write_text(value)
                result = self.run_hook(HOOKS / 'run-active', 'sleep')
                self.assertEqual((result.returncode, result.stdout, result.stderr), (0, '', ''))
                self.assertEqual(self.calls(), [])

    def test_run_active_execs_deck_engine_with_arguments(self):
        deck = self.root / 'checkout' / 'deck with space'
        deck.mkdir(parents=True)
        (deck / 'demo.toml').touch()
        engine = deck.parent / 'templates/demo/demo'
        engine.parent.mkdir(parents=True)
        engine.write_text('#!/usr/bin/python3\nimport json, sys\nprint(json.dumps(sys.argv[1:]))\n')
        engine.chmod(0o755)
        active = self.root / 'state/demo/active'
        active.parent.mkdir(parents=True)
        active.write_text(str(deck))
        result = self.run_hook(HOOKS / 'run-active', 'resume', '--notify', 'argument with spaces')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), ['resume', '--notify', 'argument with spaces', '--deck', str(deck)])

    def test_run_active_falls_back_to_its_own_engine(self):
        deck = self.root / 'external-deck'
        deck.mkdir()
        (deck / 'demo.toml').touch()
        local = self.root / 'engine'
        (local / 'hooks').mkdir(parents=True)
        shutil.copy2(HOOKS / 'run-active', local / 'hooks/run-active')
        engine = local / 'demo'
        engine.write_text('#!/usr/bin/python3\nimport json, sys\nprint(json.dumps(sys.argv[1:]))\n')
        engine.chmod(0o755)
        active = self.root / 'state/demo/active'
        active.parent.mkdir(parents=True)
        active.write_text(str(deck) + '\n')
        result = self.run_hook(local / 'hooks/run-active', 'sleep')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), ['sleep', '--deck', str(deck)])

    def test_install_dry_run_renders_without_sudo(self):
        result = self.run_hook(HOOKS / 'install.sh', '--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('@USER@', result.stdout)
        self.assertNotIn('@HOME@', result.stdout)
        self.assertNotIn('@UID@', result.stdout)
        self.assertNotIn('@RUN_ACTIVE@', result.stdout)
        self.assertNotIn('@README@', result.stdout)
        self.assertIn(str(HOOKS / 'run-active'), result.stdout)
        self.assertIn('demo-resume.service', result.stdout)
        self.assertEqual(self.calls(), [])


if __name__ == '__main__':
    unittest.main()
