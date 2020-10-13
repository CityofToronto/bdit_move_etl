"""
airflow_admin_user.py
"""
import base64
import os
import secrets
import sys

import airflow
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser

def get_email_address():
  """
  Get the domain-specific email address for the Airflow admin user.
  """
  domain_name = os.environ.get('DomainName')
  return 'airflow@{0}'.format(domain_name)

def generate_password(length):
  """
  Generates a secure random password, similar to `openssl rand -base64 [length]`.
  """
  password_bytes = secrets.token_bytes(length)
  password_b64 = base64.b64encode(password_bytes)
  return password_b64.decode()

def generate_user(password):
  """
  Creates the new Airflow admin user.
  """
  user = PasswordUser(models.User())
  user.username = 'admin'
  user.email = get_email_address()
  user.password = password
  user.superuser = True
  return user

def main():
  password = generate_password(32)
  user = generate_user(password)
  session = settings.Session()
  session.add(user)
  session.commit()
  session.close()
  print('admin:{0}'.format(password))

if __name__ == '__main__':
  main()
