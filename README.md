# bdit_move_etl

ETL scripts and configurations for MOVE, a project to modernize transportation data systems at the City of Toronto.

## Installation

The eventual goal here is full automation, but for now:

```bash
git clone https://github.com/CityofToronto/bdit_move_etl.git move_etl
cd move_etl

# look in ~/cot-env.config, get value of `PGHOST`, and:
env PGHOST="{value here}" ./scripts/deployment/rds/initDBAirflow.sh

./deploy_scripts/install.sh
./deploy_scripts/start.sh

# look in ~/cot-env.config, get value of `DomainName`, and:
env DomainName="{value here}" ./scripts/deployment/rds/airflow_admin_user.py
# save the username and password somewhere safe (e.g. password manager,
# browser saved passwords)
```

You may also have to run the following as `flashcrow_dba`, as the `flashcrow` user must have the ability to create new schemas:

```sql
GRANT ALL PRIVILEGES ON DATABASE flashcrow TO flashcrow;
```

## Config Files

These files configure various tools used as part of MOVE's Airflow / ETL setup:

- `.editorconfig`: enforces simple code conventions for all VSCode users;
- `.gitignore`: files ignored during `git` operations;
- `.gitlab-ci.yml`: GitLab CI / CD configuration;
- `.pylintrc`: Pylint rules for style-checking Python;
- `.python-version`: target version of Python;
- `appspec.yml`: used in conjunction with `deploy_scripts` for AWS CodeDeploy-managed deployments of MOVE;
- `bdit-move-etl.code-workspace`: VSCode workspace configuration;
- `LICENSE`: open-source license that MOVE is released under;
- `requirements.txt`: Python dependencies;
