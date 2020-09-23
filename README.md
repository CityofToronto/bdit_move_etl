# bdit_move_etl

ETL scripts and configurations for MOVE, a project to modernize transportation data systems at the City of Toronto.

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
