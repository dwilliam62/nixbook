# Autostart applications
#
#~/.screenlayout/vm.sh

xrandr --output Virtual-1 --mode 1920x1080
sleep 0.3

## Polybar or tint
~/.config/i3/polybar/polybar-i3 &

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
dunst -config ~/.config/i3/dunst/dunstrc &
picom --config ~/.config/i3/picom/picom.conf --animations -b &
feh --bg-fill ~/.config/i3/wallpaper/wallhaven-vq76dp_3440x1440.png &

# sxhkd
sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &

pkill variety
sleep 1
variety

