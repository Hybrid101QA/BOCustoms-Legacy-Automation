# Desktop Automation POC – Customs Legacy Swing App (.jnlp)

This repository is a proof-of-concept (POC) automation suite using **Robot Framework** and **SikuliLibrary** to automate a legacy customs application built in Java Swing and launched via `.jnlp`.

## 🧪 Objective

To simulate and validate key flows within a government customs desktop application, demonstrating desktop automation capabilities.

## 📁 Folder Structure
customs-desktop-automation/
├── swing_login.robot
├── jnlp_launcher.robot
├── images/
└── README.md

## 🔧 Tools Used

- Robot Framework  
- SikuliLibrary (image-based testing)  
- Java JNLP Launcher  
- Python 3.x  
- Mac (or Windows) OS  

## ▶️ Run Instructions

1. Install requirements:
   ```bash
   pip install robotframework
   pip install robotframework-swinglibrary

2.	Launch the customs Swing app manually or via .jnlp.
3.	Run the tests:

robot Test.robot
