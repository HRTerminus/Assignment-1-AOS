#!/usr/bin/env python3
import os
import time
import hashlib
from pathlib import Path

SUBMISSION = "submissions"
LOG = "submission_attempt_log.txt"
LOGIN_ATTEMPT = "login_attempt_log.txt"
USERNAME = "Admin"
PASSWORD = "Adminpassword"
MAX_FILE_SIZE = 5 * 1024 * 1024  

os.makedirs(SUBMISSION, exist_ok=True)

fail_count = {}
last_attempt = {}

def file_hash(filepath):
    """Compute SHA256 hash of a file for duplicate checking."""
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            h.update(chunk)
    return h.hexdigest()

def copy_file(src, dst):
    """Copy file manually in chunks."""
    with open(src, "rb") as fsrc, open(dst, "wb") as fdst:
        for chunk in iter(lambda: fsrc.read(4096), b""):
            fdst.write(chunk)

def submit_assignment():
    file = input("Choose a file to submit: ").strip()
    if not os.path.isfile(file):
        print("That file does not exist")
        return

    ext = Path(file).suffix.lower()
    if ext not in [".pdf", ".docx"]:
        print("Invalid file type, please submit .pdf or .docx")
        return

    size = os.path.getsize(file)
    if size > MAX_FILE_SIZE:
        print("File is too large and exceeds 5 MB")
        return

    filename = Path(file).name
    dest_file = os.path.join(SUBMISSION, filename)

    # Check for duplicates using hash
    if os.path.isfile(dest_file):
        if file_hash(file) == file_hash(dest_file):
            print("That is a duplicate submission, submit a different file.")
            return

    # Copy file manually
    copy_file(file, dest_file)

    with open(LOG, "a") as log_file:
        log_file.write(f"{time.ctime()} - Submitted: {filename}\n")
    print("File has been submitted successfully")

def check_submission():
    checkfile = input("Enter a filename to check: ").strip()
    if os.path.isfile(os.path.join(SUBMISSION, checkfile)):
        print("File has already been submitted")
    else:
        print("No submission has been found, please submit a file.")

def list_submissions():
    files = os.listdir(SUBMISSION)
    print("Submitted files:")
    for f in files:
        print(f)

def simulate_login():
    user = input("Username: ").strip()
    passwd = input("Password: ").strip()
    current_time = int(time.time())

    if fail_count.get(user, 0) >= 3:
        print("Account locked")
        return

    last = last_attempt.get(user)
    if last is not None:
        diff = current_time - last
        if diff < 60:
            print("Suspicious: repeated login attempts")

    last_attempt[user] = current_time

    if user == USERNAME and passwd == PASSWORD:
        print("Login is successful")
        fail_count[user] = 0
        with open(LOGIN_ATTEMPT, "a") as log_file:
            log_file.write(f"{time.ctime()} - {user} login success\n")
    else:
        print("Login failed")
        fail_count[user] = fail_count.get(user, 0) + 1
        with open(LOGIN_ATTEMPT, "a") as log_file:
            log_file.write(f"{time.ctime()} - {user} login failed\n")

def main():
    while True:
        print("\n  Assignment Submission system  ")
        print("1. Submit an assignment")
        print("2. Check if a file already submitted")
        print("3. Check all submissions")
        print("4. Simulate login")
        print("5. Exit")
        choice = input("Choose an option 1-5: ").strip()

        if choice == "1":
            submit_assignment()
        elif choice == "2":
            check_submission()
        elif choice == "3":
            list_submissions()
        elif choice == "4":
            simulate_login()
        elif choice == "5":
            confirm = input("Are you sure you want to exit? (y/n): ").strip().lower()
            if confirm == "y":
                print("Bye")
                break
            else:
                print("Staying in system")
        else:
            print("Not an option")

if __name__ == "__main__":
    main()
