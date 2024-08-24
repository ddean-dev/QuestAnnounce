set -a && source .env && set +a
rm -r "$WOW_ADDONS_FOLDER/MouseTooltip"
git submodule update
bash .packager/release.sh
mv ".release/MouseTooltip" "$WOW_ADDONS_FOLDER/MouseTooltip"
