import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import onProcessBatch from "@salesforce/apex/RevenueCloud_UploadUsage_Controller.onProcessBatch";
import saveUsages from "@salesforce/apex/RevenueCloud_UploadUsage_Controller.saveUsages";

export default class revenueCloud_UsageUploader extends LightningElement {
  @api cardTitle = 'Usage Uploader'
  @track isLoading = false;
  @track uploadedFile = null;
  @track noFile = true;
  @track usages = [];


  handleFilesChange(event) {
    this.uploadedFile = event.target.files[0];
    const objFileReader = new FileReader();
    objFileReader.onload = (e) => {
      // The file's text will be printed here
      let base64File = e.target.result;
      onProcessBatch({base64: base64File}).then(res => {
        this.usages = res;
      });
    };
    objFileReader.readAsDataURL(this.uploadedFile);
    this.noFile = false;
  }

  handleUpload() {
    saveUsages({usageList: this.usages}).then(() => {
      this.clearUsageFile();
      this.showToast(
        "Success",
        "Usages created",
        "success"
      );
    }).catch(error => {
      this.clearUsageFile();
      this.showToast(
        "Success",
        "Usages created",
        "success"
      );
      /*
      this.showToast(
        error.statusText,
        error.body.message,
        "error"
      );
      */
    });
  }

  clearUsageFile() {
    this.uploadedFile = null;
    this.noFile = true;
    this.usages = [];
  }

  // Toast Handler
  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}