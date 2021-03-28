<template>
  <div class="form-entry-group">
    <div class="form-icon">
      <font-awesome-icon :icon="['fa', icon]" />
    </div>
    <input
      :type="formType"
      :placeholder="placeholder"
      class="form-input"
      required
    />
  </div>
</template>

<script>
export default {
  props: {
    formType: {
      required: true,
      type: String,
    },
    placeholder: {
      required: true,
      type: String,
    },
    icon: {
      required: true,
      type: String,
    },
  },
}
</script>
