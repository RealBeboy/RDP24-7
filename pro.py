import os
import sys
import time
import json
import random
import string
import requests
import traceback

# ============================================================================
# COOKIE CONFIGURATION (Updated from your logs)
# ============================================================================

DEFAULT_COOKIE = "intercom-id-x55eda6t=99e9ec62-c268-4100-9279-51bb2427e1b2; intercom-device-id-x55eda6t=c799af33-f207-454d-a0a7-158b5b77b32a; intercom-session-x55eda6t=WUZPMHdrZzRBV2ZScUNFREZtbW52cVY5MnNoTGx3MnlMRGZXVGhua2MxdzlKaThLYU9DYjFYTkd1WjBtUElWSThHRnBDTGdnSDE2bTJVYVVUR0R5MHhkaDMyc2ZIZjZETzUxeDRVVDJZODA9LS1MTUZSZ3NNZFJETEZNR2RSNWZTU1lBPT0=--6fc431f6a257b0e436757f580f50771f01ad0f98; __Host-next-auth.csrf-token=1a401dc30093b0e6cb1acb0502def6a71a05fc488c6c94f9f7fef401d8019437%7Cbbf6d3de50059601dcd7a59111764aa0ba2bb0e17c2c99f7069285e5fe8cd289; next-auth.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoiLWpRZ2lSMW5xQzN1a3A1NWRNeXk4bERUdDJRSGFSclhzR28yXzJxOWNGd0NtaWN0RGtZOEdfYm40WjhZUjRFN0QxRVZvR19DSm5mSEtHeGFkNmdrX2cifQ..OpmaGzt1v9XEHdK0pOE2rA.zuf1vFQwEh0uYQB_mHcMi1MT20Oh3GO5neZthzQpECBLKYpkFclPl5ZqkmU-8YUjD-BV12ki-TfgZIGxBtXavRkbJBHAu--85wi9kIOMrwJLu_Z_WAXAk5DTmI0druBXrML6GakDiIkCdNxN3WgMXljzdd5m20S5iQKz7whR5J7tnrmKUTXhp7qEeQHCrVaC1zOthB5BXZXuIJe95vfgi92vY3EkwH5r-q43UnD_d_Wq3R36-MDOEPzVYrYGiVsANp7CSm5vyHuJSAkkeidUobXjaj6iLNrgBVzgS9IAgW-68Y3BduwgB9ELLLUZQUO1wEM5UWJdxlIMrylkOqQgzDNmwjZE4eswrjmh2d2CGHORa8W6To14t083YMJmv9tdWN-DzJ8ZAAx6sMGo5IES7t2W_fEWGHzhLT8JlfB8jmw60vKK12kZ0MJpgnU-Ub2kf4fCbu2EdS58M7FSNtYBkbUnVZxn8EH4CmUasi2RbFT6XkHGl0PgK0LsloNeicU9ddPsStWyogDoem7GmGXo-b_Gt1wE4jfawv8e35QGDaYHLUTgyaURY1cppqIBc4eZh_N3Hgv4hfUJ4uLy3e_earHCjfQMGi-h5BWtxBdphzk.u55cvHLRFlMQYWjjt_1JA3nw9zlfnDgURaaoDaJty3I; __stripe_mid=4f6746c6-ff26-484a-a9c0-0638abdaf1d7a5527e; __Secure-next-auth.callback-url=https%3A%2F%2Fbuild.blackbox.ai%2F; __Secure-next-auth.state=; __Secure-next-auth.pkce.code_verifier=; sessionid=86395e6f-4d65-4e37-a94c-7a61718b901a; __stripe_sid=4eb6fc98-1ab9-428a-b4f1-8eb6c29e504ea7364d; __Secure-next-auth.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIn0..Gr44QFNQ7LIcUQwl.KmkLD6P-0OZDMTKLfryOfdfShi-2Ppb49otJFBMt_b-zu3jno0juyvqx36mmbTxN-Tkgz_ed9d1j78KFWL9Qy8KIve3GSIVEUR1NopGu5lB0-FMKUHi-VdMXw_YP_IY6Go9KcU675SIysbFcOsflNTL9vciqPzX6vg4oi9MxCSCmDlUohNqyoLgxEAt01p1hTiO6kMpUPibzq6LOP_pvC8tO-3gEUs4mn-pPJNAliqWDHKoMblHk3y9AtEcT0LT2UaU7tr0L_Z62cJuTr7dpVxYerQ2_nLX1oUfAxxRu2zBIAl6Cgb3b1whKlJTv9gicgHudqenHD54hkBWK-xfOhfeZOMozdK4SOGvwxkyDRQpqvhnHK6wGobN22_MKs_dRtxKYoieNLhg535peVfDz512zBgGxFhsjyHD7Na8lESSYAH-Do1aPJnmNS35GIb4JtrWbsvd7HepYB43CrIVOM8HbBRMJqVzPy3smA8bA4NrWGhIg1kykte18ZGFrrC4whSv7nVMBZqsLkRmIwom5wj3zv8VPm4UWVs_7eJ4AED7dXtqsNBjMOxou.1fZTBUCLIZylyjfao2GXRg"

# ============================================================================
# SESSION GENERATOR
# ============================================================================

def generate_session_id():
    timestamp = int(time.time() * 1000)
    random_code = ''.join(random.choices(string.ascii_lowercase + string.digits, k=9))
    return f"session_{timestamp}_{random_code}"

# ============================================================================
# COOKIE PARSER
# ============================================================================

def parse_cookie_string(cookie_string):
    cookies = {}
    if cookie_string:
        for cookie in cookie_string.split(';'):
            cookie = cookie.strip()
            if '=' in cookie:
                name, value = cookie.split('=', 1)
                cookies[name] = value
    return cookies

# ============================================================================
# BLACKBOX API FUNCTIONS
# ============================================================================

def get_sandbox_id(session_id, cookies):
    url = "https://build.blackbox.ai/api/create-sandbox-for-session"
    headers = {
        "accept": "*/*",
        "content-type": "application/json",
        "referer": "https://build.blackbox.ai/chat-history"
    }
    payload = {
        "sessionId": session_id,
        "ports": [3000],
        "runDevServer": True
    }

    try:
        response = requests.post(url, headers=headers, json=payload, cookies=cookies, timeout=30)
        if response.status_code == 401:
            return {"error": "401 Unauthorized"}
        response.raise_for_status()
        data = response.json()
        if data.get("success") and "sandboxId" in data:
            return data
        return {"error": f"Failed: {data.get('message', response.text)}"}
    except Exception as e:
        return {"error": str(e)}

def create_terminal(sandbox_id, cookies):
    url = "https://build.blackbox.ai/api/terminals/create"
    headers = {
        "accept": "*/*",
        "content-type": "application/json",
        "referer": f"https://build.blackbox.ai/?sandboxId={sandbox_id}"
    }
    payload = {
        "sandboxId": sandbox_id,
        "name": f"terminal_{int(time.time() * 1000)}"
    }

    try:
        response = requests.post(url, headers=headers, json=payload, cookies=cookies, timeout=30)
        response.raise_for_status()
        data = response.json()
        if data.get("success") and "terminal" in data and "terminalId" in data["terminal"]:
            return data["terminal"]
        return {"error": f"Failed: {data.get('message', response.text)}"}
    except Exception as e:
        return {"error": str(e)}

def execute_terminal_command(sandbox_id, terminal_id, command, cookies):
    url = "https://build.blackbox.ai/api/terminals/execute"
    headers = {
        "accept": "*/*",
        "content-type": "application/json",
        "referer": f"https://build.blackbox.ai/?sandboxId={sandbox_id}"
    }
    payload = {
        "sandboxId": sandbox_id,
        "terminalId": terminal_id,
        "command": command,
        "workingDirectory": "."
    }

    try:
        # Just send the command, don't wait for response
        requests.post(url, headers=headers, json=payload, cookies=cookies, timeout=2)
        return True
    except:
        return True  # Don't care if it fails, just move on

def get_vercel_deployment_url(sandbox_id, session_id, cookies):
    url = f"https://build.blackbox.ai/?sandboxId={sandbox_id}&sessionId={session_id}&sandbox={sandbox_id}"
    
    headers = {
        "accept": "text/x-component",
        "accept-language": "en-US,en;q=0.8",
        "content-type": "text/plain;charset=UTF-8",
        # THIS IS THE FIXED ID FROM YOUR LOGS:
        "next-action": "40894b86e40a0cc1cfc09a806c89215c7898b264b8",
        "next-router-state-tree": "%5B%22%22%2C%7B%22children%22%3A%5B%22__PAGE__%22%2C%7B%7D%2Cnull%2Cnull%5D%7D%2Cnull%2Cnull%2Ctrue%5D",
        "priority": "u=1, i",
        "sec-ch-ua": "\"Brave\";v=\"143\", \"Chromium\";v=\"143\", \"Not A(Brand\";v=\"24\"",
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": "\"Windows\"",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "sec-gpc": "1",
        "referer": url
    }
    
    body = json.dumps([{
        "sandboxId": sandbox_id,
        "port": 3000,
        "contextId": f"connect-existing-{sandbox_id}",
        "waitForReady": True,
        "maxAttempts": 16,
        "intervalMs": 15000
    }])
    
    try:
        response = requests.post(url, headers=headers, data=body, cookies=cookies, timeout=60)
        response.raise_for_status()
        
        lines = response.text.strip().split('\n')
        for line in lines:
            if ':' in line:
                json_part = line.split(':', 1)[1]
                try:
                    data = json.loads(json_part)
                    if 'url' in data and data.get('url'):
                        return data['url']
                except:
                    continue
                    
        return None
    except Exception as e:
        print(f"Error getting Vercel URL: {e}")
        return None

# ============================================================================
# MAIN AUTOMATIC FUNCTION
# ============================================================================

def create_vps_with_service(service="ttyd"):
    """AUTOMATIC: Create session, sandbox, install service, get Vercel URL"""
    
    print(f"\n⚡ AUTOMATIC VPS GENERATOR - {service.upper()}")
    print("=" * 70)
    
    # Use default cookie
    cookie_string = DEFAULT_COOKIE
    cookies = parse_cookie_string(cookie_string)
    
    # Generate session
    print("\n1. Generating session...")
    session_id = generate_session_id()
    
    # Create sandbox
    print("2. Creating sandbox...")
    sandbox_data = get_sandbox_id(session_id, cookies)
    
    if "error" in sandbox_data:
        print(f"❌ Error creating sandbox: {sandbox_data['error']}")
        return None
    
    sandbox_id = sandbox_data["sandboxId"]
    
    # Create terminal
    print("3. Creating terminal...")
    terminal_data = create_terminal(sandbox_id, cookies)
    
    if "error" in terminal_data:
        print(f"⚠️ Terminal creation failed, but continuing...")
        terminal_id = None
    else:
        terminal_id = terminal_data["terminalId"]
    
    # Execute service installation command
    print(f"4. Installing {service}...")
    
    if service == "ttyd":
        # Create and execute ttyd installation
        ttyd_cmd = "curl -L -o ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && chmod +x ttyd && nohup ./ttyd -p 3000 -W bash > /dev/null 2>&1 &"
        execute_terminal_command(sandbox_id, terminal_id, ttyd_cmd, cookies)
        
    elif service == "code-server":
        # Create and execute code-server installation
        code_server_cmd = "curl -fsSL https://code-server.dev/install.sh | sh && nohup code-server --bind-addr 0.0.0.0:3000 --auth none > /dev/null 2>&1 &"
        execute_terminal_command(sandbox_id, terminal_id, code_server_cmd, cookies)
    
    # Get Vercel URL
    print("5. Getting Vercel URL...")
    
    max_attempts = 10
    vercel_url = None
    
    for attempt in range(max_attempts):
        vercel_url = get_vercel_deployment_url(sandbox_id, session_id, cookies)
        if vercel_url:
            break
        if attempt < max_attempts - 1:
            time.sleep(5)
    
    return {
        "session_id": session_id,
        "sandbox_id": sandbox_id,
        "terminal_id": terminal_id,
        "vercel_url": vercel_url,
        "service": service
    }

# ============================================================================
# BATCH AUTOMATIC GENERATOR
# ============================================================================

def batch_create_vps(count=1, service="ttyd"):
    """Create multiple VPS instances automatically"""
    print(f"\n⚡ BATCH CREATING {count} {service.upper()} VPS")
    print("=" * 70)
    
    results = []
    
    for i in range(count):
        print(f"\nCreating VPS #{i+1}/{count}...")
        result = create_vps_with_service(service)
        
        if result:
            results.append(result)
            
            if result['vercel_url']:
                print(f"✅ Vercel URL: {result['vercel_url']}")
            else:
                print(f"⚠️ No Vercel URL (sandbox still starting)")
        
        # Small delay between creations
        if i < count - 1:
            time.sleep(1)
    
    # Display results
    if results:
        print("\n" + "=" * 70)
        print(f"✅ BATCH CREATION COMPLETE - {len(results)} VPS CREATED")
        print("=" * 70)
        
        for i, result in enumerate(results, 1):
            print(f"\nVPS #{i}:")
            print(f"  Service: {result['service']}")
            print(f"  Session: {result['session_id']}")
            print(f"  Sandbox: {result['sandbox_id']}")
            if result['vercel_url']:
                print(f"  Vercel:  {result['vercel_url']}")
            print(f"  Access:  {result['vercel_url'] or 'Will be available shortly'}")
        
        # Save to file
        timestamp = int(time.time())
        filename = f"vps_batch_{timestamp}.txt"
        
        with open(filename, "w") as f:
            f.write("=" * 70 + "\n")
            f.write(f"AUTOMATIC VPS GENERATION - {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 70 + "\n\n")
            
            for idx, result in enumerate(results, 1):
                f.write(f"VPS #{idx} ({result['service']})\n")
                f.write(f"  Session ID: {result['session_id']}\n")
                f.write(f"  Sandbox ID: {result['sandbox_id']}\n")
                f.write(f"  Terminal ID: {result['terminal_id'] or 'N/A'}\n")
                f.write(f"  Vercel URL: {result['vercel_url'] or 'Not available yet'}\n")
                if result['vercel_url']:
                    f.write(f"  Access at: {result['vercel_url']}\n")
                f.write("-" * 50 + "\n")
        
        print(f"\n💾 Results saved to: {filename}")
    
    return results

# ============================================================================
# MAIN SCRIPT
# ============================================================================

def main():
    print("\n" + "=" * 70)
    print("🚀 AUTOMATIC VPS GENERATOR")
    print("=" * 70)
    print()
    
    print("Choose service:")
    print("  1. ttyd (Web Terminal)")
    print("  2. code-server (VS Code in Browser)")
    
    choice = input("\nEnter choice (1 or 2): ").strip()
    
    if choice == "1":
        service = "ttyd"
    elif choice == "2":
        service = "code-server"
    else:
        print("Invalid choice, using ttyd")
        service = "ttyd"
    
    print("\nChoose mode:")
    print("  1. Single VPS")
    print("  2. Multiple VPS (Batch)")
    
    mode = input("\nEnter choice (1 or 2): ").strip()
    
    if mode == "1":
        print(f"\nCreating single {service} VPS...")
        result = create_vps_with_service(service)
        
        if result:
            print("\n" + "=" * 70)
            print(f"✅ {service.upper()} VPS CREATED SUCCESSFULLY!")
            print("=" * 70)
            
            print(f"\nSession ID: {result['session_id']}")
            print(f"Sandbox ID: {result['sandbox_id']}")
            print(f"Terminal ID: {result['terminal_id'] or 'N/A'}")
            
            if result['vercel_url']:
                print(f"Vercel URL: {result['vercel_url']}")
                print(f"\n🌐 Access your {service} at: {result['vercel_url']}")
            else:
                print(f"\n⚠️ Vercel URL not available yet")
                print("The sandbox is still starting. Try again in 30 seconds.")
            
            # Save to file
            filename = f"{service}_vps_{int(time.time())}.txt"
            with open(filename, "w") as f:
                f.write(f"Service: {service}\n")
                f.write(f"Session ID: {result['session_id']}\n")
                f.write(f"Sandbox ID: {result['sandbox_id']}\n")
                f.write(f"Terminal ID: {result['terminal_id'] or 'N/A'}\n")
                f.write(f"Vercel URL: {result['vercel_url'] or 'Not available yet'}\n")
                f.write(f"Created: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                if result['vercel_url']:
                    f.write(f"\nAccess at: {result['vercel_url']}\n")
            
            print(f"\n💾 Info saved to: {filename}")
    
    elif mode == "2":
        try:
            count = int(input("\nHow many VPS to create? (1-10): ").strip())
            count = max(1, min(10, count))
            batch_create_vps(count, service)
        except ValueError:
            print("Invalid number, creating 3 VPS")
            batch_create_vps(3, service)
    
    else:
        print("Invalid choice, creating single VPS")
        result = create_vps_with_service(service)
        
        if result and result['vercel_url']:
            print(f"\n✅ Vercel URL: {result['vercel_url']}")
            print(f"🌐 Access at: {result['vercel_url']}")

# ============================================================================
# QUICK MODE - NO PROMPTS
# ============================================================================

def quick_mode():
    """Quick mode with no prompts - creates ttyd VPS by default"""
    print("\n⚡ QUICK MODE - AUTOMATIC TTYD VPS")
    print("=" * 70)
    
    result = create_vps_with_service("ttyd")
    
    if result and result['vercel_url']:
        print(f"\n✅ Vercel URL: {result['vercel_url']}")
        print(f"🌐 Access your web terminal at: {result['vercel_url']}")
        
        # Copy to clipboard if possible
        try:
            import pyperclip
            pyperclip.copy(result['vercel_url'])
            print("📋 URL copied to clipboard!")
        except:
            pass
    
    elif result and not result['vercel_url']:
        print(f"\n⚠️ VPS created but Vercel URL not available yet")
        print(f"Session: {result['session_id']}")
        print(f"Sandbox: {result['sandbox_id']}")
        print("Try again in 30 seconds.")
    
    return result

# ============================================================================
# ENTRY POINT
# ============================================================================

if __name__ == "__main__":
    try:
        # Check for command line arguments
        if len(sys.argv) > 1:
            arg = sys.argv[1].lower()
            
            if arg == "quick" or arg == "q":
                quick_mode()
            elif arg == "ttyd":
                result = create_vps_with_service("ttyd")
                if result and result['vercel_url']:
                    print(result['vercel_url'])
            elif arg == "code" or arg == "code-server":
                result = create_vps_with_service("code-server")
                if result and result['vercel_url']:
                    print(result['vercel_url'])
            elif arg == "batch":
                try:
                    count = int(sys.argv[2]) if len(sys.argv) > 2 else 3
                    service = sys.argv[3] if len(sys.argv) > 3 else "ttyd"
                    batch_create_vps(count, service)
                except:
                    batch_create_vps(3, "ttyd")
            else:
                main()
        else:
            main()
    
    except KeyboardInterrupt:
        print("\n\nOperation cancelled")
    except Exception as e:
        print(f"\nError: {e}")
        traceback.print_exc()
