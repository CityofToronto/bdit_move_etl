# ETL Stack Deployment

The scripts in this folder help configure our AWS environments to run Airflow, which is then used to orchestrate MOVE data pipelines.

## Accessing the ETL Stack

You will first need the `flashcrow-dev-key.pem` file, as provided by Cloud Services.  The rest of this guide assumes you have that file at `~\ssh\flashcrow-dev-key.pem`.

```powershell
ssh -i ~\ssh\flashcrow-dev-key.pem ec2-user@flashcrow-etl.intra.dev-toronto.ca
```
