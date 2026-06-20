# /plugin-version — Show installed orchestration-core version

Display the currently installed version and git SHA of the orchestration-core plugin, and compare against the latest commit in the marketplace repo if available.

## Steps

1. Read `~/.claude/plugins/installed_plugins.json` and extract the `orchestration-core@synobotix` entry with `scope: "user"`:
   - `version`
   - `gitCommitSha`
   - `lastUpdated`

2. If the marketplace repo is available locally at `~/workspace/synobotix/claude-marketplace` (or any path found via `find ~ -name "marketplace.json" -path "*/synobotix/*" 2>/dev/null | head -1`), run `git -C <repo_path> rev-parse HEAD` to get the latest commit SHA.

3. Output:

```
orchestration-core@synobotix
  Version:   <version>
  Installed: <first 7 chars of gitCommitSha>
  Updated:   <lastUpdated>
  Latest:    <first 7 chars of latest repo SHA>  ← omit if repo not found
  Status:    UP TO DATE | BEHIND (<n> commits)
```

4. To check if the plugin files on disk match what is loaded in the session, note: `/reload-plugins` is required after any reinstall for changes to take effect in the current session.
