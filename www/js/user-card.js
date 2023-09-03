const SKILL_ID_NAME_MAP = {
  3: '乾坤一掷',
  5: '崩击',
  19: '陨石魔法',
  20: '冰冻魔法',
  21: '火焰魔法',
  22: '风刃魔法',
  23: '强力陨石魔法',
  24: '强力冰冻魔法',
  25: '强力火焰魔法',
  26: '强力风刃魔法',
  95: '乱射'

}
app.component('userCard', {
  props: ['charIndex', 'charName'],
  setup(props, ctx) {
    const { charIndex, charName } = props;
    const skillList = ref([])
    const strategyData = reactive({
      actionType: 'attack',
      levelOneStop: true,
      techId: -1,
      skillId: -1
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
        if (res.data.success) {
          ElementPlus.ElNotification({
            title: 'Success',
            message: '更新成功',
            type: 'success',
          })
        }
      })
    }
    function updateCharSkillList() {
      console.log('update skill')
      axios.post('/api/getCharSkills', { charIndex: charIndex }).then(res => {
        console.log(res)
        const skillGroup = {}
        res.data.data.map(item => {
          if (skillGroup[item.skillId]) {
            skillGroup[item.skillId].children.push(item)
          } else {
            skillGroup[item.skillId] = { 
              skillName: SKILL_ID_NAME_MAP[item.skillId] || '未定义技能名字', 
              skillId: item.skillId,
              children: [item]
            }
          }
        });
        skillList.value = Object.values(skillGroup);
      })
    }
    function getCharStrategy() {
      axios.post('/api/getCharStrategy', { charIndex: charIndex }).then(res => {
        console.log(res)
        for (let key in res.data.data) {
          strategyData[key] = res.data.data[key]
        }
        if (strategyData.actionType === 'skill') {
          updateCharSkillList();
        }
      })
    }

    function autoBattleStop() {
      axios.post('/api/autoBattleStop', { charIndex: charIndex }).then(res => {
        if (res.data.success) {
          ElementPlus.ElNotification({
            title: 'Success',
            message: '停止成功',
            type: 'success',
          })
          ctx.emit('refreshChar')
        }
      })
    }

    

    function onSelectSkill(techId) {
      let target = null;
      skillList.value.forEach(group => {
        if (target) {
          return;
        }
        target = group.children.find(item => item.techId === techId)
      })
      strategyData.skillId = target ? target.skillId : -1
    }
    onMounted(() => {
      console.log(props.charIndex)
      getCharStrategy()
    })
    return { strategyData, battleOptions, skillList, actionTypeChange, onUpdateStrategy, updateCharSkillList, props, onSelectSkill, autoBattleStop }
  },
    template: `
    <el-card class="box-card">
    <template #header>
      <div class="card-header">
      <span>{{props.charName}}</span>
        <div>
            <el-button class="button" type="primary" @click="onUpdateStrategy">更新策略</el-button>
            <el-button class="button" @click="autoBattleStop">关闭自动战斗</el-button>
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
      <el-select v-model="strategyData.techId" placeholder="Select" @change="onSelectSkill">
      <el-option-group
        v-for="group in skillList"
        :key="group.skillId"
        :label="group.skillName"
      >
        <el-option
          v-for="item in group.children"
          :key="item.techId"
          :label="item.skillName + group.skillName"
          :value="item.techId"
        />
      </el-option-group>
          
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