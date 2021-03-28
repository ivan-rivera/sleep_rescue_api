<template>
  <section class="modal-content">
    <h1 class="title-text">Sign In</h1>
    <form action="" name="signin" method="post" class="form-entry">
      <FormEntry form-type="text" placeholder="E-mail" icon="at" />
      <FormEntry form-type="password" placeholder="Password" icon="key" />
      <input class="action-btn" type="submit" name="sign in" value="Continue" />
    </form>
  </section>
</template>

<script>
import FormEntry from '~/components/layout/FormEntry'
export default {
  components: { FormEntry },
}
</script>

<style>
.modal-content {
  @apply flex flex-col;
  @apply pt-5 pb-16;
}

.modal-width {
  @apply max-w-md;
}

.title-text {
  @apply pb-5;
  @apply text-center;
  @apply text-dark;
  @apply font-bold text-3xl;
}
</style>
