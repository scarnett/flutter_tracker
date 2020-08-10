import { calculateActivityDistance, calculateDistance, calculateUserDistance, hasMovedDistance } from '../utils/user-utils'

// ------------------------------------------------------------ calculateActivityDistance()
describe('calculateActivityDistance', () => {
  it('should calculate the activity distance in meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'odometer': 1069711.2
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'odometer': 1080310.2
      }
    }]

    const distance: number = calculateActivityDistance(activityData)
    expect(distance).toEqual(10599)
  })

  it('should calculate the activity distance in meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        }
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.0695005,
          'longitude': -80.6980099
        }
      }
    }]

    const distance: number = calculateActivityDistance(activityData)
    expect(distance).toEqual(8713)
  })

  it('should NOT calculate the activity distance', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'odometer': 1069711.2
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        }
      }
    }]

    const distance: number = calculateActivityDistance(activityData)
    expect(distance).toEqual(0)
  })

  it('should NOT calculate the activity distance', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'longitude': -80.7145414
        }
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.0695005
        }
      }
    }]

    const distance: number = calculateActivityDistance(activityData)
    expect(distance).toEqual(0)
  })
})

// ------------------------------------------------------------ calculateDistance()
describe('calculateDistance', () => {
  it('should calculate the distance in meters', async () => {
    const coords1: number[] = [
      35.146853,
      -80.7145414
    ]

    const coords2: number[] = [
      35.0695005,
      -80.6980099
    ]

    const distance: number = calculateDistance(coords1, coords2)
    expect(distance).toEqual(8713)
  })

  it('should NOT calculate the distance', async () => {
    const coords1: number[] = [
      35.146853
    ]

    const coords2: number[] = [
      35.0695005,
      -80.6980099
    ]

    const distance: number = calculateDistance(coords1, coords2)
    expect(distance).toEqual(0)
  })

  it('should NOT calculate the distance', async () => {
    const coords1: number[] = [
      35.146853,
      -80.7145414
    ]

    const coords2: number[] = []
    const distance: number = calculateDistance(coords1, coords2)
    expect(distance).toEqual(0)
  })
})

// ------------------------------------------------------------ calculateUserDistance()
describe('calculateUserDistance', () => {
  it('should calculate the distance in meters', async () => {
    const user: any = {
      'location': {
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        }
      }
    }

    const place: any = {
      'details': {
        'position': [
          35.0695005,
          -80.6980099
        ]
      }
    }

    const distance: number = calculateUserDistance(user, place)
    expect(distance).toEqual(8713)
  })

  it('should NOT calculate the distance', async () => {
    const user: any = {
      'location': {
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        }
      }
    }

    const place: any = {
      'details': {
        'position': []
      }
    }

    const distance: number = calculateUserDistance(user, place)
    expect(distance).toEqual(0)
  })

  it('should NOT calculate the distance', async () => {
    const user: any = {
      'location': {
        'coords': {
          'longitude': -80.7145414
        }
      }
    }

    const place: any = {
      'details': {
        'position': [
          35.0695005,
          -80.6980099
        ]
      }
    }

    const distance: number = calculateUserDistance(user, place)
    expect(distance).toEqual(0)
  })
})

// ------------------------------------------------------------ hasMovedDistance()
describe('hasMovedDistance', () => {
  it('should have moved at least 100 meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        },
        'odometer': 1069711.2
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.0695005,
          'longitude': -80.6980099
        },
        'odometer': 1080353.9
      }
    }]

    const hasMoved: boolean = hasMovedDistance(activityData, 100)
    expect(hasMoved).toBeTruthy()
  })

  it('should have moved at least 100 meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        }
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.0695005,
          'longitude': -80.6980099
        }
      }
    }]

    const hasMoved: boolean = hasMovedDistance(activityData, 100)
    expect(hasMoved).toBeTruthy()
  })

  it('should NOT have moved at least 100 meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        },
        'odometer': 1069711.2
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        },
        'odometer': 1069761.2
      }
    }]

    const hasMoved: boolean = hasMovedDistance(activityData, 100)
    expect(hasMoved).toBeFalsy()
  })

  it('should NOT have moved at least 100 meters', async () => {
    const activityData: any[] = [{
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146853,
          'longitude': -80.7145414
        }
      }
    }, {
      'location': {
        'activity': {
          'type': 'in_vehicle'
        },
        'coords': {
          'latitude': 35.146854,
          'longitude': -80.7145414
        }
      }
    }]

    const hasMoved: boolean = hasMovedDistance(activityData, 100)
    expect(hasMoved).toBeFalsy()
  })
})