from flask import Flask, render_template, request, flash, get 
from datetime import datetime 
import os

app=Flask(__name__)


if __name__ == '__main__':
    app.run(debug=True, port=5000)
