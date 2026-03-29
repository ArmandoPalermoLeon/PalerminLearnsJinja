"""
Flask Blog Platform - Learning Jinja2 & Flask Integration
This project teaches you:
- Template basics (variables, loops, conditionals)
- Filters (data transformation)
- Template inheritance (base templates)
- Static files (CSS, images)
"""

from flask import Flask, render_template, request
from datetime import datetime

app = Flask(__name__)

# Sample blog data (in a real app, this would come from a database)
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

# ===== ROUTES =====

@app.route('/')
def index():
    """Home page - display all blog posts"""
    posts = sorted(POSTS, key=lambda x: x['date'], reverse=True)
    featured = posts[0]  # Most recent post
    
    return render_template(
        'index.html',
        posts=posts,
        featured=featured,
        total_posts=len(posts)
    )


@app.route('/post/<int:post_id>')
def post_detail(post_id):
    """Single post page"""
    post = next((p for p in POSTS if p['id'] == post_id), None)
    
    if post is None:
        return "Post not found", 404
    
    # Get related posts (same tags)
    related = [
        p for p in POSTS 
        if p['id'] != post_id and any(tag in p['tags'] for tag in post['tags'])
    ]
    
    return render_template('post.html', post=post, related=related)


@app.route('/about')
def about():
    """About page"""
    stats = {
        'total_posts': len(POSTS),
        'total_views': sum(p['views'] for p in POSTS),
        'authors': len(set(p['author'] for p in POSTS)),
    }
    return render_template('about.html', stats=stats)


@app.route('/search')
def search():
    """Search posts by tag or keyword"""
    query = request.args.get('q', '').lower()
    
    if query:
        results = [
            p for p in POSTS
            if query in p['title'].lower() 
            or query in p['excerpt'].lower()
            or any(query in tag.lower() for tag in p['tags'])
        ]
    else:
        results = []
    
    return render_template('search.html', query=query, results=results)


@app.route('/author/<author>')
def author_posts(author):
    """Show all posts by a specific author"""
    posts = [p for p in POSTS if p['author'].lower() == author.lower()]
    
    if not posts:
        return "Author not found", 404
    
    return render_template('author.html', author=author, posts=posts)


# ===== ERROR HANDLERS =====

@app.errorhandler(404)
def page_not_found(e):
    """Handle 404 errors"""
    return render_template('404.html'), 404


# ===== TEMPLATE FILTERS (Custom Jinja2 Filters) =====

@app.template_filter('word_count')
def count_words(text):
    """Count words in text"""
    return len(text.split())


@app.template_filter('reading_time')
def reading_time(text):
    """Estimate reading time (200 words per minute)"""
    words = len(text.split())
    minutes = max(1, words // 200)
    return f"{minutes} min read"


if __name__ == '__main__':
    app.run(debug=True, port=5000)
