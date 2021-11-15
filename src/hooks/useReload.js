import { useState } from "react";

const useReload = () => {
  const [triggerReload, setTriggerReload] = useState(false);

  const reload = () => {
    setTriggerReload(!triggerReload);
  };

  return [triggerReload, reload];
};

export default useReload;
