#!/bin/bash

# Start SSH server
/usr/sbin/sshd

# Jalankan Cloudflare Tunnel
cloudflared tunnel --no-autoupdate run --token eyJhIjoiNjZiYzVlYjhjOTMzOTI2MmMyZTAyYzhmOTQyMzU1MzIiLCJ0IjoiMWE2MmViNmQtYTdmYy00NzY4LWJjNTEtM2VlZDlkOTNmOGJiIiwicyI6Ik5USTJNVGc0TlRJdFpUYzNNQzAwT1dSaExXRXlOREl0TmpjMFpEZ3hORFE0Tm1VMSJ9
