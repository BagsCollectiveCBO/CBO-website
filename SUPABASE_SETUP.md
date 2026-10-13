# Admin dashboard setup

The dashboard lets the verified account `collectivebags33@gmail.com` add, edit and remove leadership, approach, community update and gallery project cards. The website is static, so Supabase stores the shared content and enforces write access in the database. Do not put a Supabase `service_role` key or any other secret in `index.html`.

## 1. Create the content table

1. Create a Supabase project.
2. In the Supabase SQL Editor, run [`supabase/schema.sql`](./supabase/schema.sql). It creates or updates the content table, seeds the current leadership, approach and in-progress Community Car Wash project, and applies public-read/admin-only-write row-level security policies. The script can be rerun safely to apply schema changes.
3. In the Supabase project API settings, copy the **Project URL** and **publishable key** (or legacy `anon` key). Never use the `service_role` key in the website.

## 2. Connect Clerk

1. In Clerk, connect the Clerk application to the Supabase project using Clerk's Supabase integration. In Supabase, confirm Clerk is enabled as a third-party authentication provider.
2. Customize Clerk session tokens to include both claims:

   ```json
   {
     "role": "authenticated",
     "email": "{{user.primary_email_address}}"
   }
   ```

   The `email` claim is checked by the database policies. Keep the role claim: Supabase requires it to recognize Clerk users as authenticated.
3. Make sure `collectivebags33@gmail.com` is a verified primary email in Clerk. Members can sign in with their existing Clerk accounts using **Member sign in**. If members should be able to create accounts themselves, enable sign-up in Clerk; the page also provides **Create account**. Invite or create the CBO admin account from Clerk.

## 3. Configure the website

In `index.html`, set `supabaseUrl` to the Supabase Project URL and `supabasePublishableKey` to the publishable (or legacy `anon`) key. Replace the existing Clerk test publishable key with the live publishable key for the Clerk application connected to Supabase before deploying.

Deploy the updated static site. Visitors will see content from Supabase, and members can sign in with Clerk. The **Get involved** menu provides member sign-in and account creation; the dashboard is shown only to the verified CBO email. Database policies independently reject writes from every other account.

## Managed sections

- **Leadership** cards show the title as the person's name and the description as their role.
- **Our approach** cards show a principle and its description.
- **Gallery projects** appear on the public Gallery section with a Planning, In progress or Completed status.
- **Community updates** cards create a public updates section; the section stays hidden while it has no cards.

The dashboard and database support adding, editing and removing these cards. Project cards use an illustrated cover; image uploads are not configured. To change the fixed page copy (such as the homepage introduction or contact details), edit `index.html` directly.
