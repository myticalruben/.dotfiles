import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class WelcomeTest(unittest.TestCase):
    def test_check_is_non_interactive(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = os.environ.copy()
            env["HOME"] = tmp
            env["XDG_CONFIG_HOME"] = str(Path(tmp) / ".config")
            result = subprocess.run(
                [sys.executable, "distro/first-run/mytical-welcome", "--check"],
                cwd=ROOT, env=env, text=True, capture_output=True, input="",
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("python3", result.stdout)
            self.assertIn("nix", result.stdout)
            self.assertIn("hyprctl", result.stdout)


if __name__ == "__main__":
    unittest.main()
