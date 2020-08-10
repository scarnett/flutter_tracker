# Setup
```bash
npm install -g firebase-tools
firebase login
```

# Tests
```bash
npm test
```

# Deploy firebase functions

```bash
firebase deploy --only functions --project flutter-tracker
```

# Deploy firestore rules

```bash
firebase deploy --only firestore:rules --project flutter-tracker
```

# Structure
```
functions/
  db/
    name/
      onWrite.f.ts

    name2/
      onCreate.f.ts

    name3/
      onUpdate.f.ts

    name4/
      onCreate.f.ts
      onUpdate.f.ts
      onDelete.f.ts

  http/
    endpointName.f.ts

  schedule/
    jobName.f.ts

  index.ts
```

# Notes
When you deploy these functions a lib/ folder will be generated that contains the transpiled javascript files that get deployed to firebase.
It is highly recommended to delete this folder if it exists prior to deploying the functions. This will ensure that a clean build is being deployed.
