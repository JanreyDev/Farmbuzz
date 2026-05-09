<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Account - FarmBuzz</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f9fafb;
            color: #111827;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .logo {
            font-size: 24px;
            font-weight: 800;
            color: #10b981;
            margin-bottom: 24px;
            display: block;
        }
        h1 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 16px;
        }
        p {
            color: #6b7280;
            line-height: 1.6;
            margin-bottom: 24px;
        }
        .info-box {
            background-color: #fef2f2;
            border: 1px solid #fee2e2;
            padding: 16px;
            border-radius: 8px;
            text-align: left;
            margin-bottom: 24px;
        }
        .info-box ul {
            margin: 8px 0 0 20px;
            padding: 0;
            font-size: 14px;
            color: #991b1b;
        }
        .contact-btn {
            background-color: #10b981;
            color: white;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 600;
            display: inline-block;
            transition: background-color 0.2s;
        }
        .contact-btn:hover {
            background-color: #059669;
        }
        .footer {
            margin-top: 32px;
            font-size: 12px;
            color: #9ca3af;
        }
    </style>
</head>
<body>
    <div class="container">
        <span class="logo">FarmBuzz</span>
        <h1>Request Account Deletion</h1>
        <p>We're sorry to see you go. If you would like to delete your FarmBuzz account and all associated data, please follow the instructions below.</p>
        
        <div class="info-box">
            <strong>What data will be deleted?</strong>
            <ul>
                <li>Your profile information (Name, Mobile Number)</li>
                <li>Your farm details and activity logs</li>
                <li>Messages and social interactions</li>
                <li>Personalized settings and preferences</li>
            </ul>
        </div>

        <p>To request deletion, please contact our support team with your registered mobile number:</p>
        
        <a href="mailto:support@farmbuzz.app?subject=Account Deletion Request" class="contact-btn">
            Email Support
        </a>

        <div class="footer">
            &copy; {{ date('Y') }} FarmBuzz. All rights reserved.
        </div>
    </div>
</body>
</html>
