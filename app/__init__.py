from flask import Flask
from flask_cors import CORS

def create_app(): #função de fábrica para criar a aplicação Flask, configurar o CORS e registrar os blueprints das rotas
    app = Flask(__name__)
    
    CORS(app)
    
    from .routes.usuarios import usuarios_bp
    from .routes.pets import pets_bp
    from .routes.servicos import servicos_bp
    
    app.register_blueprint(usuarios_bp, url_prefix='/usuarios')
    app.register_blueprint(pets_bp, url_prefix='/pets')
    app.register_blueprint(servicos_bp, url_prefix='/servicos') #Blueprints são "mini-aplicações" Flask que agrupam rotas relacionadas
    
    return app