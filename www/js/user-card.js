app.component('userCard', {
  props: ['charIndex', 'charName'],
  setup(props) {
    const { charIndex, charName } = props;
    const skillList = ref([])
    const strategyData = reactive({
      actionType: 'attack',
      useSkill: '',
      levelOneStop: true,
    })
    const battleOptions = [
      { label: '普攻优先', value: 'attack' },
      { label: '技能优先', value: 'skill' },
      { label: '治疗优先', value: 'health'},
      { label: '防御', value: 'guard' },
    ]
    function actionTypeChange(value) {
      if (value === 'skill') {
        updateCharSkillList()
      }
    }
    function onUpdateStrategy() {
      axios.post('/api/setCharStrategy', { charIndex: charIndex, strategy: strategyData }).then(res => {
        console.log(res)
      })
    }
    function updateCharSkillList() {
      console.log('update skill')
      axios.post('/api/getCharSkillList', { charIndex: charIndex }).then(res => {
        console.log(res)
        skillList.value = res.data;
      })
    }
    function getCharStrategy() {
      axios.post('/api/getCharStrategy', { charIndex: charIndex }).then(res => {
        console.log(res)
        strategyData.value = res.data;
      })
    }
    onMounted(() => {
      console.log(props.charIndex)
      getCharStrategy()
    })
    return { strategyData, battleOptions, skillList, actionTypeChange, onUpdateStrategy, updateCharSkillList, props }
  },
    template: `
    <el-card class="box-card">
    <template #header>
      <div class="card-header">
      <span>{{props.charName}}</span>
        <div>
            <el-button class="button" type="primary" @click="onUpdateStrategy">更新策略</el-button>
            <el-button class="button">关闭自动战斗</el-button>
        </div>
      </div>
    </template>
    <div class="list-item">
      <span class="label">攻击方式：</span>
      <el-select v-model="strategyData.actionType" @change="actionTypeChange"  placeholder="Select">
          <el-option
          v-for="item in battleOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value"
          />
      </el-select>
    </div>
    <div class="list-item" v-if="strategyData.actionType === 'skill'">
      <span class="label">使用技能：</span>
      <el-select v-model="strategyData.useSkill" placeholder="Select">
          <el-option
          v-for="item in skillList"
          :key="item.value"
          :label="item.label"
          :value="item.value"
          />
      </el-select>
      <el-icon class="op-icon" @click="updateCharSkillList"><Refresh /></el-icon>
    </div>
    <div class="list-item">
      <span class="label">遇到1级停手：</span>
      <el-checkbox v-model="strategyData.levelOneStop" />
    </div>
    </el-card>
        
    
    `
  })