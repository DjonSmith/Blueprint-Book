# Step 1: Create Docker volume
docker volume create mysql_data

# Step 2: Run MySQL container
docker run -d --name mysql-server -e MYSQL_ROOT_PASSWORD=my-secret-pw -v mysql_data:/var/lib/mysql -p 3306:3306 mysql:latest

# Step 3: Open MySQL console (interactive, requires user input)
Start-Sleep -Seconds 5
docker exec -it mysql-server mysql -u root -p