---
title: "Microsoft Entra:   SSO design from the start"
tags:
  - Microsoft Entra
  - SSO
---

Microsoft Entra:   SSO design from the start

***Microsoft Entra SSO using PHP or Javascript***

Here’s how you can implement Single Sign-On (SSO) authentication and authorization with **Microsoft Entra ID (formerly Azure AD)** in **PHP** and **JavaScript**.

---

### **PHP Code Example**
Using the [Microsoft Authentication Library (MSAL)](https://github.com/AzureAD/microsoft-authentication-library-for-php) or OAuth 2.0 endpoints:

#### **Dependencies**
1. Install a library like `league/oauth2-client` via Composer:
   ```bash
   composer require league/oauth2-client
   ```

#### **Code**
```php
<?php
require 'vendor/autoload.php';

use League\OAuth2\Client\Provider\GenericProvider;

session_start();

// Replace with your Microsoft Entra (Azure AD) app details
$clientId = 'YOUR_CLIENT_ID';
$clientSecret = 'YOUR_CLIENT_SECRET';
$tenantId = 'YOUR_TENANT_ID';
$redirectUri = 'https://your-app-url.com/callback';

$provider = new GenericProvider([
    'clientId'                => $clientId,
    'clientSecret'            => $clientSecret,
    'redirectUri'             => $redirectUri,
    'urlAuthorize'            => "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize",
    'urlAccessToken'          => "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token",
    'urlResourceOwnerDetails' => '',
    'scopes'                  => ['openid', 'profile', 'email']
]);

// Handle the OAuth 2.0 Authorization Flow
if (!isset($_GET['code'])) {
    $authorizationUrl = $provider->getAuthorizationUrl();
    $_SESSION['oauth2state'] = $provider->getState();
    header('Location: ' . $authorizationUrl);
    exit;
} elseif (empty($_GET['state']) || ($_GET['state'] !== $_SESSION['oauth2state'])) {
    unset($_SESSION['oauth2state']);
    exit('Invalid state');
} else {
    try {
        $accessToken = $provider->getAccessToken('authorization_code', [
            'code' => $_GET['code']
        ]);

        // Use the access token to get the user's profile
        $request = $provider->getAuthenticatedRequest(
            'GET',
            'https://graph.microsoft.com/v1.0/me',
            $accessToken
        );
        $response = $provider->getResponse($request);
        $userData = $response->getBody()->getContents();
        echo $userData;
    } catch (\League\OAuth2\Client\Provider\Exception\IdentityProviderException $e) {
        exit($e->getMessage());
    }
}
```

---

### **JavaScript Example**
Using **Microsoft Authentication Library (MSAL.js)** for front-end authentication:

#### **Dependencies**
Install MSAL.js using npm or include it via a CDN:
```bash
npm install @azure/msal-browser
```

Or include via a script tag:
```html
<script src="https://alcdn.msauth.net/browser/2.32.0/js/msal-browser.min.js"></script>
```

#### **Code**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microsoft Entra Authentication</title>
</head>
<body>
    <button id="login">Login with Microsoft</button>
    <button id="logout">Logout</button>
    <div id="user-info"></div>

    <script>
        const msalConfig = {
            auth: {
                clientId: "YOUR_CLIENT_ID",
                authority: "https://login.microsoftonline.com/YOUR_TENANT_ID",
                redirectUri: "https://your-app-url.com",
            }
        };

        const msalInstance = new msal.PublicClientApplication(msalConfig);

        document.getElementById('login').onclick = async () => {
            try {
                const loginResponse = await msalInstance.loginPopup({
                    scopes: ["user.read"]
                });
                console.log('Login successful:', loginResponse);

                const account = msalInstance.getAllAccounts()[0];
                const tokenResponse = await msalInstance.acquireTokenSilent({
                    account,
                    scopes: ["user.read"]
                });

                const userResponse = await fetch('https://graph.microsoft.com/v1.0/me', {
                    headers: {
                        'Authorization': `Bearer ${tokenResponse.accessToken}`
                    }
                });

                const userData = await userResponse.json();
                document.getElementById('user-info').innerText = `Hello, ${userData.displayName}`;
            } catch (error) {
                console.error('Error during login:', error);
            }
        };

        document.getElementById('logout').onclick = () => {
            msalInstance.logout();
        };
    </script>
</body>
</html>
```

---

### **Key Components**
1. **Scopes**: Both implementations request `openid`, `profile`, and `email` (and optionally `user.read` for MS Graph API).
2. **Microsoft Graph API**: Used to fetch user profile data after successful authentication.
3. **OAuth 2.0 Flow**: PHP demonstrates the backend handling of OAuth 2.0, while JavaScript uses the front-end MSAL.js library.

Replace placeholders (`YOUR_CLIENT_ID`, `YOUR_CLIENT_SECRET`, `YOUR_TENANT_ID`, etc.) with your actual Microsoft Entra app details.


***Here are references for the PHP and JavaScript implementations provided:***

---

### **PHP Implementation References**

1. **Microsoft Authentication Library (MSAL)** for PHP:
   - [MSAL Overview](https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-overview)
   - [League OAuth2 Client Library](https://oauth2-client.thephpleague.com/)

2. **Microsoft Entra (Azure AD) OAuth 2.0 Endpoints**:
   - [Microsoft Identity Platform OAuth 2.0 Authorization Code Flow](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)

3. **Microsoft Graph API**:
   - [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/overview)

4. **PHP Example of Microsoft Graph API with OAuth**:
   - [Microsoft Graph PHP Example](https://learn.microsoft.com/en-us/graph/sdks/sdk-installation)

---

### **JavaScript Implementation References**

1. **MSAL.js (Microsoft Authentication Library)**:
   - [MSAL.js Library Documentation](https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-overview)
   - [MSAL.js GitHub Repository](https://github.com/AzureAD/microsoft-authentication-library-for-js)

2. **Using MSAL.js with Azure AD**:
   - [MSAL.js Quickstart](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-v2-javascript)

3. **Microsoft Identity Platform Documentation**:
   - [Microsoft Identity Platform Overview](https://learn.microsoft.com/en-us/azure/active-directory/develop/)

4. **Example JavaScript Application**:
   - [JavaScript SPA Integration with MSAL](https://learn.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-javascript-spa)

5. **Microsoft Graph JavaScript SDK**:
   - [Microsoft Graph JavaScript SDK Documentation](https://learn.microsoft.com/en-us/graph/sdks/sdk-installation)

---

### **General Resources**
- **OAuth 2.0 and OpenID Connect**:
  - [OAuth 2.0 and OpenID Connect Protocols](https://oauth.net/2/)
  - [OIDC Primer](https://openid.net/connect/)

These references provide the foundational knowledge and detailed steps to implement SSO with Microsoft Entra (Azure AD) in your applications.
