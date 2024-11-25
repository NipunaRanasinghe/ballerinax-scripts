import requests
import json
import sys
from typing import List, Dict

def get_repos(org: str, pattern: str, output_file: str) -> None:
    """
    Fetch repositories from a GitHub organization and save matching ones to a JSON file.
    
    Args:
        org: GitHub organization name
        pattern: Pattern to match repository names against
        output_file: Path to save the JSON output
    """
    # GitHub API base URL
    base_url = f"https://api.github.com/orgs/{org}/repos"
    headers = {
        "Accept": "application/vnd.github+json",
        # Add your GitHub token here if needed
        # "Authorization": "Bearer YOUR_GITHUB_TOKEN"
    }
    
    matching_repos: List[Dict] = []
    page = 1
    
    while True:
        # GitHub API uses pagination
        params = {
            "per_page": 100,  # Max items per page
            "page": page
        }
        
        try:
            response = requests.get(base_url, headers=headers, params=params)
            response.raise_for_status()
            
            repos = response.json()
            if not repos:  # No more repos to fetch
                break
                
            # Filter repos based on pattern
            for repo in repos:
                if repo["name"].startswith(pattern):
                    matching_repos.append({
                        "name": repo["name"],
                        "url": repo["html_url"],
                        "description": repo["description"],
                        "created_at": repo["created_at"],
                        "updated_at": repo["updated_at"]
                    })
            
            page += 1
            
        except requests.RequestException as e:
            print(f"Error fetching repositories: {e}", file=sys.stderr)
            sys.exit(1)
    
    # Save results to JSON file
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({"matching_repositories": matching_repos}, f, indent=2)
        print(f"Found {len(matching_repos)} matching repositories. Results saved to {output_file}")
    
    except IOError as e:
        print(f"Error writing to output file: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <organization> <pattern> <output_file>")
        print("Example: python script.py ballerina-platform module-ballerina matching_repos.json")
        sys.exit(1)
    
    org = sys.argv[1]
    pattern = sys.argv[2]
    output_file = sys.argv[3]
    
    get_repos(org, pattern, output_file)
