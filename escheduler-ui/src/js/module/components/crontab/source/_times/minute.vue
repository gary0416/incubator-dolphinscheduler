<template>
  <div class="minute-model">
    <div class="v-crontab-from-model">
      <x-radio-group v-model="radioMinute" vertical>
        <div class="list-box">
          <x-radio label="everyMinute">
            <span class="text">{{$t('每一分钟')}}</span>
          </x-radio>
        </div>
        <div class="list-box">
          <x-radio label="intervalMinute">
            <span class="text">{{$t('每隔')}}</span>
            <m-input-number :min="0" :max="59" :props-value="parseInt(intervalPerformVal)" @on-number="onIntervalPerform"></m-input-number>
            <span class="text">{{$t('分执行 从')}}</span>
            <m-input-number :min="0" :max="59" :props-value="parseInt(intervalStartVal)" @on-number="onIntervalStart"></m-input-number>
            <span class="text">{{$t('分开始')}}</span>
          </x-radio>
        </div>
        <div class="list-box">
          <x-radio label="specificMinute">
            <span class="text">{{$t('具体分钟数(可多选)')}}</span>
            <x-select multiple :placeholder="$t('请选择具体分钟数')" v-model="specificMinutesVal" @on-change="onspecificMinutes">
              <x-option
                      v-for="item in selectMinuteList"
                      :key="item.value"
                      :value="item.value"
                      :label="item.label">
              </x-option>
            </x-select>
          </x-radio>
        </div>
        <div class="list-box">
          <x-radio label="cycleMinute">
            <span class="text">{{$t('周期从')}}</span>
            <m-input-number :min="0" :max="59" :props-value="parseInt(cycleStartVal)" @on-number="onCycleStart"></m-input-number>
            <span class="text">{{$t('到')}}</span>
            <m-input-number :min="0" :max="59" :props-value="parseInt(cycleEndVal)" @on-number="onCycleEnd"></m-input-number>
            <span class="text">{{$t('分')}}</span>
          </x-radio>
        </div>
      </x-radio-group>
    </div>
  </div>
</template>
<script>
  import _ from 'lodash'
  import i18n from '../_source/i18n'
  import { selectList, isStr } from '../util/index'
  import mInputNumber from '../_source/input-number'

  export default {
    name: 'minute',
    mixins: [i18n],
    data () {
      return {
        minuteValue: '*',
        radioMinute: 'everyMinute',
        selectMinuteList: selectList['60'],
        intervalPerformVal: 5,
        intervalStartVal: 3,
        specificMinutesVal: [],
        cycleStartVal: 1,
        cycleEndVal: 1
      }
    },
    props: {
      minuteVal: String,
      value: {
        type: String,
        default: '*'
      }
    },
    model: {
      prop: 'value',
      event: 'minuteValueEvent'
    },
    methods: {
      // 间隔执行时间（1）
      onIntervalPerform (val) {
        console.log(val)
        this.intervalPerformVal = val
        if (this.radioMinute === 'intervalMinute') {
          this.minuteValue = `${this.intervalStartVal}/${this.intervalPerformVal}`
        }
      },
      // 间隔开始时间（2）
      onIntervalStart (val) {
        this.intervalStartVal = val
        if (this.radioMinute === 'intervalMinute') {
          this.minuteValue = `${this.intervalStartVal}/${this.intervalPerformVal}`
        }
      },
      // 具体分
      onspecificMinutes (arr) {
      },
      // 周期开始值
      onCycleStart (val) {
        this.cycleStartVal = val
        if (this.radioMinute === 'cycleMinute') {
          this.minuteValue = `${this.cycleStartVal}-${this.cycleEndVal}`
        }
      },
      // 周期结束值
      onCycleEnd (val) {
        this.cycleEndVal = val
        if (this.radioMinute === 'cycleMinute') {
          this.minuteValue = `${this.cycleStartVal}-${this.cycleEndVal}`
        }
      },
      // 重置每一分
      everyReset () {
        this.minuteValue = '*'
      },
      // 重置间隔分
      intervalReset () {
        this.minuteValue = `${this.intervalStartVal}/${this.intervalPerformVal}`
      },
      // 重置具体分钟数
      specificReset () {
        if (this.specificMinutesVal.length) {
          this.minuteValue = this.specificMinutesVal.join(',')
        } else {
          this.minuteValue = '*'
        }
      },
      // 重置周期分分钟数
      cycleReset () {
        this.minuteValue = `${this.cycleStartVal}-${this.cycleEndVal}`
      },
      /**
       * 解析参数值
       */
      analyticalValue () {
        return new Promise((resolve, reject) => {
          let $minuteVal = _.cloneDeep(this.value)
          // 间隔分
          let $interval = isStr($minuteVal, '/')
          // 具体分
          let $specific = isStr($minuteVal, ',')
          // 周期分
          let $cycle = isStr($minuteVal, '-')

          // 每一分
          if ($minuteVal === '*') {
            this.radioMinute = 'everyMinute'
            this.minuteValue = '*'
            return
          }

          // 正整数（分）
          if ($minuteVal.length === 1 && _.isInteger(parseInt($minuteVal)) ||
            $minuteVal.length === 2 && _.isInteger(parseInt($minuteVal))
          ) {
            this.radioMinute = 'specificMinute'
            this.specificMinutesVal = [$minuteVal]
            return
          }

          // 间隔分
          if ($interval) {
            this.radioMinute = 'intervalMinute'
            this.intervalStartVal = parseInt($interval[0])
            this.intervalPerformVal = parseInt($interval[1])
            this.minuteValue = `${this.intervalStartVal}/${this.intervalPerformVal}`
            return
          }

          // 具体分钟数
          if ($specific) {
            this.radioMinute = 'specificMinute'
            this.specificMinutesVal = $specific
            return
          }

          // 周期分
          if ($cycle) {
            this.radioMinute = 'cycleMinute'
            this.cycleStartVal = parseInt($cycle[0])
            this.cycleEndVal = parseInt($cycle[1])
            this.minuteValue = `${this.cycleStartVal}/${this.cycleEndVal}`
            return
          }
          resolve()
        })
      }
    },
    watch: {
      // 导出值
      minuteValue (val) {
        this.$emit('minuteValueEvent', val)
      },
      // 选中类型
      radioMinute (val) {
        switch (val) {
          case 'everyMinute':
            this.everyReset()
            break
          case 'intervalMinute':
            this.intervalReset()
            break
          case 'specificMinute':
            this.specificReset()
            break
          case 'cycleMinute':
            this.cycleReset()
            break
        }
      },
      // 具体分钟数
      specificMinutesVal (arr) {
        this.minuteValue = arr.join(',')
      }
    },
    beforeCreate () {
    },
    created () {
      this.analyticalValue().then(() => {
        console.log('数据结构解析成功！')
      })
    },
    beforeMount () {
    },
    mounted () {

    },
    beforeUpdate () {
    },
    updated () {
    },
    beforeDestroy () {
    },
    destroyed () {
    },
    computed: {},
    components: { mInputNumber }
  }
</script>

<style lang="scss" rel="stylesheet/scss">
  .minute-model {

  }


</style>
