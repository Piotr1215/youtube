"""Check the public reset recipe for manifest and legacy decks."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


JUSTFILE = Path(__file__).resolve().parents[3] / "justfile"


@unittest.skipUnless(shutil.which("just"), "just is not installed")
class JustResetTests(unittest.TestCase):
    # Create a deck outside the checkout to exercise invocation_directory.
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.deck = Path(self.temp.name)

    # Run the repository recipe from the deck.
    def run_reset(self, *args):
        return subprocess.run(["just", "--justfile", str(JUSTFILE), "reset", *args],
                              cwd=self.deck, capture_output=True, text=True)

    # Reject every argument before the manifest engine runs.
    def test_manifest_reset_rejects_arguments(self):
        (self.deck / "demo.toml").write_text("invalid manifest")
        for arg in ("fresh", "--fresh", "other"):
            with self.subTest(arg=arg):
                result = self.run_reset(arg)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("usage: just reset", result.stderr)
                self.assertNotIn("manifest", result.stderr)

    # Keep legacy reset scripts runnable with no forwarded arguments.
    def test_legacy_reset_runs_script(self):
        script = self.deck / "reset.sh"
        script.write_text("#!/bin/sh\nprintf 'legacy:%s\\n' \"$#\"\n")
        script.chmod(0o755)
        result = self.run_reset("fresh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("legacy:0", result.stdout)


if __name__ == "__main__":
    unittest.main()
