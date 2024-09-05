set -a && source .env && set +a
rm -r "$WOW_ADDONS_FOLDER/QuestAnnounce"
git submodule update
bash .packager/release.sh
mv ".release/QuestAnnounce" "$WOW_ADDONS_FOLDER/QuestAnnounce"
