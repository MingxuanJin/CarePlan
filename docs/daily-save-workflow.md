# Daily Save Workflow

This project uses a small Git workflow so daily progress is easy to preserve.

## Daily routine

1. Make the day's changes.
2. Check the result locally.
3. Commit with a short message.
4. Push to GitHub.

## Commit format

Use a compact message that names the day and the feature:

- `Day 1: initial design doc`
- `Day 2: MVP scaffold`
- `Day 3: database schema`

## Helper script

Run:

```bash
./scripts/save-day.sh "Day 2: MVP scaffold"
```

That script runs:

- `git add .`
- `git commit -m "..."`

After that, push with:

```bash
git push
```

## GitHub remote

Before the first push, connect the repository to your GitHub repo:

```bash
git remote add origin https://github.com/MingxuanJin/<repo-name>.git
git push -u origin main
```

Replace `<repo-name>` with the actual repository name you create on GitHub.

