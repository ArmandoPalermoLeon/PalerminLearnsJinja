from flask import Flask, render_template, request
from datetime import datetime 

app = Flask(__name__)

POSTS = [
    {
        'id': 1,
        'title': 'Getting Started with Flask',
        'author': 'Alice Johnson',
        'date': datetime(2024, 3, 15),
        'excerpt': 'Learn the basics of Flask and build your first web application.',
        'content': 'Flask is a lightweight and flexible Python web framework...',
        'tags': ['Flask', 'Python', 'Web Development'],
        'image': 'https://via.placeholder.com/400x250?text=Flask',
        'views': 1240,
    },
    {
        'id': 2,
        'title': 'Mastering Jinja2 Templates',
        'author': 'Bob Smith',
        'date': datetime(2024, 3, 10),
        'excerpt': 'Deep dive into Jinja2 templating engine and advanced techniques.',
        'content': 'Jinja2 is the most popular template engine for Python...',
        'tags': ['Jinja2', 'Templates', 'Python'],
        'image': 'https://via.placeholder.com/400x250?text=Jinja2',
        'views': 856,
    },
    {
        'id': 3,
        'title': 'Building RESTful APIs with Flask',
        'author': 'Carol White',
        'date': datetime(2024, 2, 28),
        'excerpt': 'Create robust and scalable APIs using Flask and best practices.',
        'content': 'REST APIs are the backbone of modern web applications...',
        'tags': ['API', 'Flask', 'REST'],
        'image': 'https://via.placeholder.com/400x250?text=REST+API',
        'views': 2103,
    },
]

#########
### Creating routes

@app.route('/')
def index():
    """Home page - to display the vlog"""
    posts = sorted(POSTS, key=lambda x: x['date'], reverse=True)
    featured = posts[0]
    return render_template('index.html', posts=posts,featured=featured, total_posts=len(posts))


