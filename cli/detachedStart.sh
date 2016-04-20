screen -S "naRobot" -d -m
screen -r "naRobot" -X stuff $'while true; do ./naRobot default.toml; sleep 1; done\n'