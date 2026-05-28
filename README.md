# Secure Journal Application

## DevSecOps Capstone Project on AWS

A secure cloud-native journal application deployed on AWS using DevSecOps best practices.

---

## Features

* User Registration & Login
* JWT Authentication
* Full CRUD Journal Management
* Dockerized Deployment
* HTTPS using CloudFront
* CI/CD using GitHub Actions
* AWS Cloud Infrastructure
* CloudWatch Monitoring

---

## Technologies Used

* Flask
* MySQL RDS
* Docker
* Nginx
* AWS EC2
* AWS ALB
* AWS CloudFront
* GitHub Actions
* JWT Authentication
* Flask-Bcrypt

---

## AWS Architecture

User Browser
↓
CloudFront HTTPS
↓
Application Load Balancer
↓
Private EC2 Ubuntu Server
↓
Dockerized Flask Application
↓
RDS MySQL Database

---

## Security Features

* Password Hashing using Flask-Bcrypt
* JWT Authentication
* HTTPS Encryption
* SQL Injection Mitigation
* XSS Protection
* Security Headers
* Rate Limiting

---

## CI/CD Pipeline

GitHub Actions automatically deploys the application whenever code is pushed to the main branch.

---

## Monitoring

AWS CloudWatch is used for:

* CPU Monitoring
* Network Monitoring
* Health Checks

---

## Live Application

https://da1iop03ingr6.cloudfront.net/app

---

## GitHub Repository

https://github.com/AthulPS7/secure-journal-app

---

## Project Outcome

Successfully implemented a secure DevSecOps architecture on AWS with CI/CD automation, HTTPS security, monitoring and full CRUD functionality.
