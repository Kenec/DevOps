#!/usr/bin/env python
import sys

def Authenticate():
  validPassword = 'secret'
  inputPassword = raw_input('Please Enter Your Passowrd: ')

  if validPassword == inputPassword:
      print 'You have access!'
  else:
      print 'Access Denied!'
      sys.exit(0)

  print 'Welcome'

def checkAge():
    if len(sys.argv) > 1:
        name = sys.argv[1]
    else:
        name = raw_input('Enter Name: ')

    
    if len(sys.argv) > 2:
        age = int(sys.argv[2])
    else:
        age = int(raw_input('Enter Age: '))

    sayHello = 'Hello ' + name + ', '

    if age == 100:
        sayAge = 'You are already 100 years old'
    elif age < 100:
        sayAge = 'You will be 100 years in ' + str(100 - age) + ' years'
    else:
        sayAge = 'You turned 100 years ' + str(age - 100) + ' years ago'

    print sayHello, sayAge

accept_input = int(raw_input('Enter 1 to Authenticate or 2 to determine you 100th Birthday: '))

if accept_input == 1:
  Authenticate()
elif accept_input == 2:
  checkAge()
else:
    print 'Wrong Input'
