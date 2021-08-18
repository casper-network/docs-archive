# How to Translate the Documentation

## Overview
You can contribute to the existing translations of the documentation or add your own language if it's missing. Translation workflow:

* Strings to be translated are extracted and turned into translation catalogs as [PO files](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html)
  * The translation catalogs are kept under the locale directory (the subdirectory `en` keeps the original strings in English)
  * After adding the source (English) catalogs, it is not recommended to modify any translations under the locales directory manually
* Whenever there is a change in the source strings, the changes will be automatically pulled by the [translation platform](https://transifex.com)
* Completely translated & reviewed traslation files on the translation platform are automatically pushed to GitHub as new pull requests
* After each translation update coming from the translation platform, the final documentation is automatically regenerated and [published](https://caspernetwork.readthedocs.io/en/latest/) with new changes in a few minutes
* It is possibe to switch between the existing translated versions of the documentation easily by using the hovering button on the right bottom corner of a page on the [published documentation](https://caspernetwork.readthedocs.io/en/latest/)

## Contributing to the existing languages

Follow these steps to contribute to contribute to an existing translation:

1. Sign up on the [translation platform](https://transifex.com) (Choose the open-source option. Do not sign up for a trial.)
2. Go to [our translation project dashboard](https://www.transifex.com/caspernetwork/docs-11/dashboard/) and request to join your language's team
3. Join the [Casper Translators group](https://t.me/joinchat/9prJkTdxBM82NTI0) to coordinate with your fellow translators, and ping your language's coordinator to be accepted to the team
4. Do your translations on the platform with a friendly UI
5. After your changes propagate to the published documentation, make sure it looks good. If you see something which doesn't look right, go back to the translation platform, and fix it.

## Adding a new language to the translations

Follow the steps below to get your own language added to the translations list:

1. Sign up on the [translation platform](https://transifex.com) (Choose the open-source option. Do not sign up for a trial.)
2. Go to [our translation project dashboard](https://www.transifex.com/caspernetwork/docs-11/dashboard/) and request a new language
3. Join the [Casper Translators group](https://t.me/joinchat/9prJkTdxBM82NTI0) to coordinate with your fellow translators. Ping the translation project coordinator, and introduce yourself to get your language added.
4. If all goes well, you will become the coordinator of the newly added language. Then you can start translating immediately, and you will also be responsible for recruiting new translators and reviewers to your language's team.
5. After you have your first file completely translated, reviewed and merged on GitHub, ping the coordinator of the translation project to get your translated documentation published.

## Tips

* Make use of the translation memory and the glossary on the translation platform. **Consistency is the key!**
  * As you translate the documentation to your language, a translation memory is automatically built based on your translations. When you select a string to translate on the platform, it brings up a list of existing translations which have a similar source string. If it's 100% match, and the context/meaning is right (it's your responsibility to judge as the translator), then you can just copy & paste the existing translation. If the match rate is lower, you can still copy & paste the old translation to use it as a starting point for your translation.
* Never ever directly use machine-translated content. Though, it may help at certain cases to have a better understanding.
* Be careful about the special characters. `, ', and " are different characters. Respect the original string in their uses.
