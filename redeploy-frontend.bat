@echo off
echo Rebuilding frontend with updated API URLs...
cd RevHub
call npm run build
echo Build complete!

echo Committing changes to git...
cd ..
git add .
git commit -m "Update API URLs to use EC2 instance IP"
git push origin main

echo Frontend updated and pushed to repository!
echo Now run these commands on EC2:
echo cd ~/revhub-project
echo git pull origin main
echo docker stop revhub-frontend
echo docker rm revhub-frontend
echo docker build -t revhub-frontend ./RevHub/RevHub
echo docker run -d --name revhub-frontend -p 4200:80 revhub-frontend