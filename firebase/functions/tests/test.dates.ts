import moment = require('moment')
import { dateDiff } from '../utils/date-utils'

// ------------------------------------------------------------ calculateActivityDistance()
describe('staleActivity', () => {
  it('should be a 30sec diff', async () => {
    const timezone: string = 'America/New_York'
    const date1: Date = moment('2020-01-01T10:15:00.299').toDate()
    const date2: Date = moment('2020-01-01T10:15:30.299').toDate()
    const diff: moment.Duration = dateDiff(date1, date2, timezone)
    expect(diff.asSeconds()).toEqual(30)
  })

  it('should be a 5min diff', async () => {
    const timezone: string = 'America/New_York'
    const date1: Date = moment('2020-01-01T10:15:00.299').toDate()
    const date2: Date = moment('2020-01-01T10:20:00.299').toDate()
    const diff: moment.Duration = dateDiff(date1, date2, timezone)
    expect(diff.asMinutes()).toEqual(5)
  })

  it('should be a 15min diff', async () => {
    const timezone: string = 'America/New_York'
    const date1: Date = moment('2020-01-01T10:15:00.299').toDate()
    const date2: Date = moment('2020-01-01T10:30:00.299').toDate()
    const diff: moment.Duration = dateDiff(date1, date2, timezone)
    expect(diff.asMinutes()).toEqual(15)
  })

  it('should be a 59min diff', async () => {
    const timezone: string = 'America/New_York'
    const date1: Date = moment('2020-01-01T10:15:00.299').toDate()
    const date2: Date = moment('2020-01-01T11:14:00.299').toDate()
    const diff: moment.Duration = dateDiff(date1, date2, timezone)
    expect(diff.asMinutes()).toEqual(59)
  })

  it('should be a 1hr diff', async () => {
    const timezone: string = 'America/New_York'
    const date1: Date = moment('2020-01-01T10:15:00.299').toDate()
    const date2: Date = moment('2020-01-01T11:15:00.299').toDate()
    const diff: moment.Duration = dateDiff(date1, date2, timezone)
    expect(diff.asHours()).toEqual(1)
  })
})
