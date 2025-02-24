#### Cache Feed Use Case

#### Data:
- Feed items

#### Primary course (happy path):
1. Execute "Save Feed Items" command with above data.
2. System deletes old cache data.
3. System encodes feed items.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

### Load Feed From Cache Use case

#### Primary Course:
1. Execute "Load Image Feed" command with above data
2. System Fetches feed data from cache.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Error course (Sad path):
1. System delivers error.

#### Expired cache course (sad path):
1. System deletes cache.
2. System delivers no feed images.

#### Empty cache course (sad path):
1. System delivers no feed images.
