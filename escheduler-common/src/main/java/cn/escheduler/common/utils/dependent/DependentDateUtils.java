/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package cn.escheduler.common.utils.dependent;

import cn.escheduler.common.model.DateInterval;
import cn.escheduler.common.utils.DateUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class DependentDateUtils {

    /**
     * get last day interval list
     * @param businessDate
     * @param hourNumber
     * @return
     */
    public static List<DateInterval> getLastHoursInterval(Date businessDate, int hourNumber){
        List<DateInterval> dateIntervals = new ArrayList<>();
        for(int index = hourNumber; index > 0; index--){
            Date lastHour = DateUtils.getSomeHourOfDay(businessDate, index);
            Date beginTime = DateUtils.getStartOfHour(lastHour);
            Date endTime = DateUtils.getEndOfHour(lastHour);
            dateIntervals.add(new DateInterval(beginTime, endTime));
        }
        return dateIntervals;
    }

    /**
     * get last day interval list
     * @param businessDate
     * @param someDay
     * @return
     */
    public static List<DateInterval> getLastDayInterval(Date businessDate, int someDay){

        List<DateInterval> dateIntervals = new ArrayList<>();
        for(int index = someDay; index > 0; index--){
            Date lastDay = DateUtils.getSomeDay(businessDate, -index);

            Date beginTime = DateUtils.getStartOfDay(lastDay);
            Date endTime = DateUtils.getEndOfDay(lastDay);
            dateIntervals.add(new DateInterval(beginTime, endTime));
        }
        return dateIntervals;
    }

    /**
     * get interval between last month first day and last day
     * @param businessDate
     * @return
     */
    public static List<DateInterval> getLastMonthInterval(Date businessDate) {

        Date firstDayThisMonth = DateUtils.getFirstDayOfMonth(businessDate);
        Date lastDay = DateUtils.getSomeDay(firstDayThisMonth, -1);
        Date firstDay = DateUtils.getFirstDayOfMonth(lastDay);
        return getDateIntervalListBetweenTwoDates( firstDay, lastDay);
    }


    /**
     * get interval on first/last day of the last month
     * @param businessDate
     * @param isBeginDay
     * @return
     */
    public static List<DateInterval> getLastMonthBeginInterval(Date businessDate, boolean isBeginDay) {

        Date firstDayThisMonth = DateUtils.getFirstDayOfMonth(businessDate);
        Date lastDay = DateUtils.getSomeDay(firstDayThisMonth, -1);
        Date firstDay = DateUtils.getFirstDayOfMonth(lastDay);
        if(isBeginDay){
            return getDateIntervalListBetweenTwoDates(firstDay, firstDay);
        }else{
            return getDateIntervalListBetweenTwoDates(lastDay, lastDay);
        }
    }

    /**
     * get interval between monday to sunday of last week
     * default set monday the first day of week
     * @param businessDate
     * @return
     */
    public static List<DateInterval> getLastWeekInterval(Date businessDate) {
        Date mondayThisWeek = DateUtils.getMonday(businessDate);
        Date sunday = DateUtils.getSomeDay(mondayThisWeek, -1);
        Date monday = DateUtils.getMonday(sunday);
        return getDateIntervalListBetweenTwoDates(monday, sunday);
    }

    /**
     * get interval on the day of last week
     * default set monday the first day of week
     * @param businessDate
     * @param dayOfWeek monday:1,tuesday:2,wednesday:3,thursday:4,friday:5,saturday:6,sunday:7
     * @return
     */
    public static List<DateInterval> getLastWeekOneDayInterval(Date businessDate, int dayOfWeek) {
        Date mondayThisWeek = DateUtils.getMonday(businessDate);
        Date sunday = DateUtils.getSomeDay(mondayThisWeek, -1);
        Date monday = DateUtils.getMonday(sunday);
        Date destDay = DateUtils.getSomeDay(monday, dayOfWeek -1);
        return getDateIntervalListBetweenTwoDates(destDay, destDay);
    }

    public static List<DateInterval> getDateIntervalListBetweenTwoDates(Date firstDay, Date lastDay) {
        List<DateInterval> dateIntervals = new ArrayList<>();
        while(!firstDay.after(lastDay)){
            Date beginTime = DateUtils.getStartOfDay(firstDay);
            Date endTime = DateUtils.getEndOfDay(firstDay);
            dateIntervals.add(new DateInterval(beginTime, endTime));
            firstDay = DateUtils.getSomeDay(firstDay, 1);
        }
        return dateIntervals;
    }
}