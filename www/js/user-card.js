app.component('userCard', {
    setup() {
      const count = ref(0)
      const battleType = ref('attack')
      const battleOptions = [
        { label: '普攻', value: 'attack' },
        { label: '技能', value: 'skill' },
        { label: '治疗', value: 'health'}
      ]
      return { count, battleType, battleOptions }
    },
    template: `
    <el-card class="box-card">
    <template #header>
      <div class="card-header">
      <span>Card name</span>
        <div>
            <el-button class="button" type="primary">更新策略</el-button>
            <el-button class="button">关闭自动战斗</el-button>
        </div>
      </div>
    </template>
    <div class="list-item">
    <span class="label">攻击方式：</span>
    <el-select v-model="battleType" placeholder="Select">
        <el-option
        v-for="item in battleOptions"
        :key="item.value"
        :label="item.label"
        :value="item.value"
        />
    </el-select>
    </div>
    </el-card>
        
    
    `
  })