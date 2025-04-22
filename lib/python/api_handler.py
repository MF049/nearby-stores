import requests
import json
import os
from flask import Flask, request, jsonify
from flask_cors import CORS # type: ignore

app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Resource Sharing

# Replace with your actual TomTom API key
TOMTOM_API_KEY = "q0XVWYmmGkUW4oWMWvlFxD0AVOdmxtXl"
BASE_URL = "https://api.tomtom.com/search/2/nearbySearch/.json"

@app.route('/api/distance', methods=['GET'])
def get_distance():
    try:
        # Get parameters from request
        start_lat = request.args.get('start_lat')
        start_lon = request.args.get('start_lon')
        end_lat = request.args.get('end_lat')
        end_lon = request.args.get('end_lon')
        
        if not all([start_lat, start_lon, end_lat, end_lon]):
            return jsonify({"error": "All coordinates are required"}), 400
        
        # Calculate route using TomTom API
        route_url = f"https://api.tomtom.com/routing/1/calculateRoute/{start_lat},{start_lon}:{end_lat},{end_lon}/json"
        params = {
            "key": TOMTOM_API_KEY,
            "traffic": "true"
        }
        
        response = requests.get(route_url, params=params)
        data = response.json()
        
        # Extract distance from response
        if 'routes' in data and len(data['routes']) > 0:
            # Distance is in meters, convert to kilometers
            distance_km = data['routes'][0]['summary']['lengthInMeters'] / 1000
            return jsonify({"distance": distance_km})
        else:
            return jsonify({"error": data}), 400
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Get port from environment variable or use 5000 as default
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
