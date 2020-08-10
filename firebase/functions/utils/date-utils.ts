import moment from 'moment-timezone'

export function dateDiff(date1: Date, date2: Date, timezone: string): moment.Duration {
  const dt1: moment.Moment = moment(date1).tz(timezone)
  const dt2: moment.Moment = moment(date2).tz(timezone)
  const duration = moment.duration(dt2.diff(dt1))
  return duration
}
