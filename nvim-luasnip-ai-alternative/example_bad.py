import subprocess


def fetch_user(client, user_id):
    try:
        return client.get(f"/users/{user_id}")
    except ConnectionError as err:
        raise RuntimeError("fetch failed")


def deploy(env):
    try:
        subprocess.run(["make", "deploy", env], check=True)
    except subprocess.CalledProcessError:
        pass
