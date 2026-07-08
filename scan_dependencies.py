import os
import sys
import json
import time
import urllib.request
import urllib.error

# Config
ORGS = ["RPDevs-Builds", "RPDevs-Vault"]
GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_PAT")

if not GH_TOKEN:
    print("Error: GH_TOKEN, GITHUB_TOKEN, or GH_PAT environment variable is required.")
    sys.exit(1)

# Common dependency files to scan for in the root directory
DEP_FILES_MAP = {
    "package.json": "Node.js (NPM)",
    "requirements.txt": "Python (Pip)",
    "pyproject.toml": "Python (Poetry/Pip)",
    "poetry.lock": "Python (Poetry)",
    "Pipfile": "Python (Pipenv)",
    "go.mod": "Go Modules",
    "Cargo.toml": "Rust (Cargo)",
    "addon.xml": "Kodi Addon",
    "CMakeLists.txt": "C/C++ (CMake)",
    "Makefile": "Makefile / Build script",
    "Dockerfile": "Docker Image",
    "docker-compose.yml": "Docker Compose",
}

def make_request(url):
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "dependency-manager-scanner")
    req.add_header("Authorization", f"token {GH_TOKEN}")
    req.add_header("Accept", "application/vnd.github.v3+json")
    
    # Retry on rate limiting or server errors
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req) as response:
                # Handle link header for pagination
                link_header = response.headers.get("Link", "")
                data = json.loads(response.read().decode("utf-8"))
                return data, link_header
        except urllib.error.HTTPError as e:
            if e.code == 403 and "rate limit" in str(e.read()):
                print("Rate limit reached. Sleeping 60s...")
                time.sleep(60)
                continue
            elif e.code in [500, 502, 503, 504]:
                print(f"Server error {e.code}. Retrying in 5s...")
                time.sleep(5)
                continue
            else:
                raise e
    raise Exception(f"Failed to fetch {url} after 3 attempts")

def get_org_repos(org):
    print(f"Fetching repositories for org: {org}...")
    repos = []
    page = 1
    while True:
        url = f"https://api.github.com/orgs/{org}/repos?per_page=100&page={page}"
        try:
            data, link = make_request(url)
            if not data:
                break
            repos.extend(data)
            if 'rel="next"' not in link:
                break
            page += 1
        except Exception as e:
            print(f"Error fetching repos for {org}: {e}")
            break
    print(f"Found {len(repos)} repositories in {org}.")
    return repos

def scan_repo_root_contents(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/contents/"
    found_deps = {}
    try:
        data, _ = make_request(url)
        if isinstance(data, list):
            for item in data:
                name = item.get("name")
                if name in DEP_FILES_MAP:
                    found_deps[name] = {
                        "type": DEP_FILES_MAP[name],
                        "path": item.get("path"),
                        "html_url": item.get("html_url")
                    }
    except urllib.error.HTTPError as e:
        # Ignore empty/new repos that return 404 or 403 for contents
        if e.code not in [404, 403]:
            print(f"  Error checking contents for {owner}/{repo}: {e}")
    except Exception as e:
        print(f"  Error checking contents for {owner}/{repo}: {e}")
    return found_deps

def main():
    start_time = time.time()
    registry = {}
    total_scanned = 0
    total_with_deps = 0

    for org in ORGS:
        repos = get_org_repos(org)
        for repo_info in repos:
            name = repo_info["name"]
            owner = repo_info["owner"]["login"]
            is_fork = repo_info["fork"]
            description = repo_info.get("description") or ""
            html_url = repo_info["html_url"]
            
            # Simple progress logging
            total_scanned += 1
            print(f"[{total_scanned}] Scanning {owner}/{name}...")
            
            found_deps = scan_repo_root_contents(owner, name)
            
            if found_deps:
                total_with_deps += 1
                registry[f"{owner}/{name}"] = {
                    "owner": owner,
                    "name": name,
                    "html_url": html_url,
                    "description": description,
                    "is_fork": is_fork,
                    "dependency_files": found_deps
                }
            
            # Be gentle with API rate limits (50ms sleep between repos)
            time.sleep(0.05)

    # Save structured json registry
    registry_path = "dependency_registry.json"
    with open(registry_path, "w") as f:
        json.dump(registry, f, indent=2)
    print(f"Saved registry to {registry_path}")

    # Generate Markdown Summary for GITHUB_STEP_SUMMARY
    summary_md = []
    summary_md.append("# Dependency Scan Report")
    summary_md.append(f"Scanned **{total_scanned}** repositories across `{', '.join(ORGS)}`.")
    summary_md.append(f"Identified **{total_with_deps}** repositories containing dependency files.\n")
    summary_md.append("## Repositories & Detected Dependency Files\n")
    summary_md.append("| Repository | Description | Type / Files |")
    summary_md.append("| --- | --- | --- |")
    
    for repo_key, repo_data in sorted(registry.items()):
        files_str = ", ".join([f"[{f}]({info['html_url']}) ({info['type']})" for f, info in repo_data["dependency_files"].items()])
        desc = repo_data["description"]
        if len(desc) > 80:
            desc = desc[:77] + "..."
        summary_md.append(f"| [{repo_key}]({repo_data['html_url']}) | {desc} | {files_str} |")

    # Output to step summary if in GitHub Action environment
    step_summary_env = os.environ.get("GITHUB_STEP_SUMMARY")
    if step_summary_env:
        with open(step_summary_env, "w") as f:
            f.write("\n".join(summary_md))
    else:
        # Print a short stdout summary
        print("\n=== Scan Complete ===")
        print(f"Total Repositories Scanned: {total_scanned}")
        print(f"Total with Dependency Files: {total_with_deps}")
        print(f"Duration: {time.time() - start_time:.2f} seconds")

if __name__ == "__main__":
    main()
