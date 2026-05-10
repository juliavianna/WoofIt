from flask import Flask
from flask_cors import CORS

def create_app():
    """
    Application Factory Pattern: em vez de criar o app Flask no nível do módulo,
    criamos dentro de uma função. Isso permite criar instâncias diferentes
    para testes e para produção, evitando efeitos colaterais na importação.
    """
    app = Flask(__name__)
    
    CORS(app)
    
    from .routes.usuarios import usuarios_bp
    from .routes.pets import pets_bp
    from .routes.servicos import servicos_bp
    
    app.register_blueprint(usuarios_bp, url_prefix='/usuarios')
    app.register_blueprint(pets_bp, url_prefix='/pets')
    app.register_blueprint(servicos_bp, url_prefix='/servicos')
    
    return app