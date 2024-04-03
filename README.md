# decidim-app-cache-problems

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the open-source repository for test_decidim_app, based on [Decidim](https://github.com/decidim/decidim).

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Start a postgres 15 database. If you have Docker configured, you can simply run `docker compose up`;
2. There's a `.env` file in the root directory containing appropriate variables for connecting to the Docker database;
3. Prepare de database:
```bash
rails db:create
rails db:migrate
rails db:seed # custom seeds
```
4. Enable dev caching: `rails dev:cache`;
5. Start the server: `rails s`.

You're good to go!

## Reproduce machine translations cache bug

1. Access the running app on [localhost:3000](http://localhost:3000);
2. Access the only published process;
3. Access the _Proposals_ tab;
4. Click on _New proposal_ (you will have to log in using `user@example.org` and `decidim123456789`);
5. Create a new proposal and publish it;
6. Switch the app locale to a different locale from the one you used to create the proposal;
7. Try to toggle between _original text_ and _automatically-translated text_. It should work fine on the proposal page;
8. The proposal should appear on the parent process "overview" page (`The process` tab) as an highlighted proposal;
7. Try to toggle between _original text_ and _automatically-translated text_. **It should not work here**.

### Discovered solution

Do this after the [Reproduce machine translations cache bug](#reproduce-machine-translations-cache-bug) section.

1. Stop the app;
2. Checkout the `cache-accounts-for-machine-translations` branch;
3. Restart the app and access it on [localhost:3000](http://localhost:3000);
4. Access the only published process "overview" page;
5. The proposal created previously should still be highlighted here;
6. Try to toggle between _original text_ and _automatically-translated text_. **It should work fine by now**.

[Solution here](https://github.com/derayo94/decidim-app-cache-problems/pull/1/files)