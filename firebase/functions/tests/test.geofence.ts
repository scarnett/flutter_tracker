import { buildGeofenceNotifications, getNotificationUsers, filterNotificationUserSettings } from '../utils/geofence-utils'

// ------------------------------------------------------------ buildGeofenceNotifications()
describe('buildGeofenceNotifications', () => {
  it('should not have any messages', async () => {
    const placeData: any = {
      'details': {
        'name': 'Home'
      },
      'notifications': {}
    }

    const messages: any[] = buildGeofenceNotifications('1234567890abc', 'abcdefghijklmnopqrstuvwxyz123', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(0)
  })

  it('should not have any messages because no users have toggled their notifications', async () => {
    const placeData: any = {
      'details': {
        'name': 'Home'
      },
      'notifications': {
        'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': false,
            'leaving': false
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': false,
            'leaving': false
          }
        },
        'empZYBYiC7V4QR7Dz6f1tJSqd213': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': false,
            'leaving': false
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': false,
            'leaving': false
          }
        },
        'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': false,
            'leaving': false
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': false,
            'leaving': false
          }
        }
      }
    }

    let messages: any[] = buildGeofenceNotifications('kc6Lj8QTOjfE9o7RzAddFGtjuNE2', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(0)

    messages = buildGeofenceNotifications('empZYBYiC7V4QR7Dz6f1tJSqd213', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(0)

    messages = buildGeofenceNotifications('XZsQII6p3jWvxBUwClb1R6YlH7z2', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(0)
  })

  it('should have some messages', async () => {
    const placeData: any = {
      'details': {
        'name': 'Home'
      },
      'notifications': {
        'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': true,
            'leaving': true
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': true,
            'leaving': true
          }
        },
        'empZYBYiC7V4QR7Dz6f1tJSqd213': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': false,
            'leaving': false
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': true,
            'leaving': true
          }
        },
        'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': true,
            'leaving': true
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': true,
            'leaving': true
          }
        }
      }
    }

    let messages: any[] = buildGeofenceNotifications('kc6Lj8QTOjfE9o7RzAddFGtjuNE2', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(2)

    messages = buildGeofenceNotifications('empZYBYiC7V4QR7Dz6f1tJSqd213', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(2)

    messages = buildGeofenceNotifications('XZsQII6p3jWvxBUwClb1R6YlH7z2', 'MY751OZNhRTVWglg4IBy', 'ENTERING_GEOFENCE', 'entering', {}, placeData)
    expect(messages.length).toEqual(1)
  })
})

// ------------------------------------------------------------ getNotificationUsers()
describe('getNotificationUsers', () => {
  it('should not return any user notification settings', async () => {
    const placeData: any = {
      'notifications': {}
    }

    const users: any[] = getNotificationUsers('kc6Lj8QTOjfE9o7RzAddFGtjuNE2', placeData)
    expect(users.length).toEqual(0)
  })

  it('should not return any user notification settings', async () => {
    const placeData: any = {
      'notifications': {}
    }

    const users: any[] = getNotificationUsers('kc6Lj8QTOjfE9o7RzAddFGtjuNE2', placeData)
    expect(users.length).toEqual(0)
  })

  it('should return some user notification settings', async () => {
    const placeData: any = {
      'notifications': {
        'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': true,
            'leaving': true
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': true,
            'leaving': true
          }
        },
        'empZYBYiC7V4QR7Dz6f1tJSqd213': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': false,
            'leaving': false
          },
          'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
            'entering': true,
            'leaving': true
          }
        },
        'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
          'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
            'entering': false,
            'leaving': false
          },
          'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
            'entering': true,
            'leaving': true
          },
          'empZYBYiC7V4QR7Dz6f1tJSqd213': {
            'entering': true,
            'leaving': true
          }
        }
      }
    }

    const fromUid: string = 'kc6Lj8QTOjfE9o7RzAddFGtjuNE2'
    const users: any[] = getNotificationUsers(fromUid, placeData)
    expect(users.length).toEqual(2)

    const user1: string[] = Object.keys(users[0])
    expect(user1[0]).toEqual('XZsQII6p3jWvxBUwClb1R6YlH7z2')

    const user1Notifications: any = users[0]['XZsQII6p3jWvxBUwClb1R6YlH7z2']
    expect(Object.keys(user1Notifications)[0]).toEqual(fromUid)
    expect(user1Notifications[fromUid]).toEqual({ "entering": true, "leaving": true })

    const user2: string[] = Object.keys(users[1])
    expect(user2[0]).toEqual('empZYBYiC7V4QR7Dz6f1tJSqd213')

    const user2Notifications: any = users[1]['empZYBYiC7V4QR7Dz6f1tJSqd213']
    expect(Object.keys(user2Notifications)[0]).toEqual(fromUid)
    expect(user2Notifications[fromUid]).toEqual({ "entering": true, "leaving": true })
  })
})

// ------------------------------------------------------------ filterNotificationUserSettings()
describe('filterNotificationUserSettings', () => {
  it('should not return any user notification settings', async () => {
    const settings: any[] = filterNotificationUserSettings(['1234567890abc'], {})
    expect(settings).toEqual({})
  })

  it('should not return any user notification settings', async () => {
    const data: any = {
      'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
        'entering': false,
        'leaving': false
      },
      'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
        'entering': false,
        'leaving': false
      },
      'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
        'entering': true,
        'leaving': true
      }
    }

    const settings: any[] = filterNotificationUserSettings(['1234567890abc'], data)
    expect(settings).toEqual({})
  })

  it('should return some user notification settings', async () => {
    const data: any = {
      'P2gTDAc6yFYQgOHNpDV98GOjQFB3': {
        'entering': false,
        'leaving': false
      },
      'XZsQII6p3jWvxBUwClb1R6YlH7z2': {
        'entering': false,
        'leaving': false
      },
      'kc6Lj8QTOjfE9o7RzAddFGtjuNE2': {
        'entering': true,
        'leaving': true
      }
    }

    const settings: any[] = filterNotificationUserSettings(['kc6Lj8QTOjfE9o7RzAddFGtjuNE2'], data)
    expect(settings).toEqual({ "kc6Lj8QTOjfE9o7RzAddFGtjuNE2": { "entering": true, "leaving": true } })
  })
})