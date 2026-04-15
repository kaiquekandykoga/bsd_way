# AGENTS.md

## Running the tool

```bash
bundle exec bin/bsd_way
```

Requires:
- Ruby with bundler
- **Ollama running locally** with `llama3.2:3b` model loaded
- The tool connects to `http://localhost:11434/api/generate`

## Behavior

`bin/bsd_way` regenerates `README.md` from YAML data files, auto-commits, and pushes to remote.

## Data files

- `data/cloud_providers.yml`
- `data/sites.yml`
- `data/operating_systems.yml`
- `data/youtube_channels.yml`

Each entry has `name`, `url`, and optional `notes`/`verified_date` fields.