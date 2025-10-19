from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import chess
import random

class ChessEngine:
    def get_best_move(self):
        board = chess.Board()
        moves = list(board.legal_moves)
        return random.choice(moves) if moves else None

class ContentWriter:
    def generate_content(self, topic):
        contents = {
            "هوش مصنوعی": "هوش مصنوعی تحول عظیمی در تکنولوژی ایجاد کرده است.",
            "شطرنج": "شطرنج بازی استراتژیک با تاریخچه کهن است.",
            "برنامه‌نویسی": "برنامه‌نویسی هنر حل مسئله با کد است."
        }
        return contents.get(topic, "محتوا تولید شد")

class APIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "active", 
                "message": "Natiq Backend Running"
            }).encode())
        else:
            self.send_error(404)
    
    def do_POST(self):
        if self.path == '/api/chess/move':
            engine = ChessEngine()
            move = engine.get_best_move()
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                "best_move": str(move),
                "status": "success"
            }).encode())
            
        elif self.path == '/api/writer/generate':
            writer = ContentWriter()
            content = writer.generate_content('هوش مصنوعی')
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                "content": content,
                "status": "success"
            }).encode())
        else:
            self.send_error(404)
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

print("🚀 Starting Natiq Backend on http://localhost:8000")
server = HTTPServer(('localhost', 8000), APIHandler)
server.serve_forever()
