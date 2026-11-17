import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class SetupDryRunTest(unittest.TestCase):
    def test_dry_run_covers_session_and_theme_links(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = os.environ.copy()
            env.update({
                "HOME": tmp,
                "XDG_CONFIG_HOME": str(Path(tmp) / ".config"),
            })
            result = subprocess.run(
                [sys.executable, "setup.py", "--dry-run"],
                cwd=ROOT, env=env, text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            for needle in (
                "session-start", "session-splash", "set-zsh-shell",
                "gtk-theme", "btop-theme", "Wallpapers",
            ):
                self.assertIn(needle, result.stdout)


if __name__ == "__main__":
    unittest.main()
