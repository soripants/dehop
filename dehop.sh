#!/bin/bash

### dotfile storage location - Edit this
homedir="/home/sori"
dotfiles="$homedir/dotfiles"
universal="Universal"
packagefiles="$dotfiles/packages"
########################################



### Distribution selection
echo "Select DE:"
echo "Gnome (1)"
echo "KDE (2)"
echo "i3 (3)"
echo "Budgie (4)"
echo "Openbox (5)"
echo "Choice:   "
read dist

if [ "$dist" -eq "1" ]
then
	dist="Gnome"
elif [ "$dist" -eq "2" ]
then
	dist="KDE"
elif [ "$dist" -eq "3" ]
then
	dist="i3"
elif [ "$dist" -eq "4" ]
then
	dist="Budgie"
elif [ "$dist" -eq "5" ]
then
    dist="Openbox"
else
	echo "No valid DE selected"
	exit
fi

echo "$dist chosen. Starting customization"

## Setup directories

if [ ! -d "$dotfiles/$dist" ]
then
	mkdir -p "$dotfiles/$dist/local/share"
	mkdir "$dotfiles/$dist/config"
fi

if [ ! -d "$dotfiles/$dist/config" ]
then
	mkdir -p "$dotfiles/$dist/config"
fi

if [ ! -d "$dotfiles/$dist/local" ]
then
	mkdir -p "$dotfiles/$dist/local/share"
fi

if [ ! -d "$dotfiles/$universal" ]
then
	mkdir -p "$dotfiles/$universal"
fi

### Parse universal packages
cd "${0%/*}"
if [ ! -d "./tmp" ]
then
	mkdir tmp
fi
ls -1 "$dotfiles/$universal" | grep -v "config" | grep -v "local" > tmp/univ
ls -1 "$dotfiles/$universal/config" > tmp/univconf
ls -1 "$dotfiles/$universal/local/share" > tmp/univloc
ls -1 "$dotfiles/$dist" | grep -v "config" | grep -v "local" > tmp/demain

### Remove existing dots and link up new dots
rm -rf "$homedir/.config"
rm -rf "$homedir/.local"
ln -s "$dotfiles/$dist/config/" "$homedir/.config"
ln -s "$dotfiles/$dist/local/" "$homedir/.local"

while read p; do
	rm "$homedir/.$p"
	ln -s "$dotfiles/$dist/$p" "$homedir/.$p"
done < tmp/demain

while read p; do
	rm "$homedir/.$p"
	ln -s "$dotfiles/$universal/$p" "$homedir/.$p"
done < tmp/univ

while read p; do
	rm "$homedir/.config/$p"
	ln -s "$dotfiles/$universal/config/$p" "$homedir/.config/$p"
done < tmp/univconf

while read p; do
	rm "$homedir/.local/share/$p"
	ln -s "$dotfiles/$universal/local/share/$p" "$homedir/.local/share/$p"
done < tmp/univloc
	
### Option to remove old packages
echo "Remove packages from old DE? (y/N): "
read remchoice

if [ "$remchoice" = "y" -o "$remchoice" = "Y" ]
then
	echo "Type name of old DE (case sensitive): "
	read oldde
	sudo eopkg remove $(cat "$packagefiles/$oldde")
fi

### Install packages for new DE
sudo eopkg install $(cat "$packagefiles/$dist")


#### Clean up
cd "${0%/*}"
rm -rf tmp
