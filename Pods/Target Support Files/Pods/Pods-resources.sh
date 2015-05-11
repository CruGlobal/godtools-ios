#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY=$(cd "${1%/*}" && pwd)
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "GTViewController/GTViewController/Resources/AbyssinicaSIL-R.ttf"
  install_resource "GTViewController/GTViewController/Resources/arrow.png"
  install_resource "GTViewController/GTViewController/Resources/arrow@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Buttonlines.png"
  install_resource "GTViewController/GTViewController/Resources/Buttonlines_large.png"
  install_resource "GTViewController/GTViewController/Resources/fiftytap.mp3"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_bot.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_E.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_NE.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_S.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_SE.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_SW.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_top.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer@2x.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Shadow.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Shadow@2x.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Tap_Circle.png"
  install_resource "GTViewController/GTViewController/Resources/line.png"
  install_resource "GTViewController/GTViewController/Resources/NotoSansEthiopic-Bold.ttf"
  install_resource "GTViewController/GTViewController/Resources/NotoSansEthiopic-Regular.ttf"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Export.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Export@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Help.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Help@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Info.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Info@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Menu.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Menu@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Switch.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Switch@2x.png"
  install_resource "GTViewController/GTViewController/Resources/URL_Button.png"
  install_resource "GTViewController/GTViewController/Resources/URL_Button@2x.png"
  install_resource "GTViewController/GTViewController/Resources/urlbutton.png"
  install_resource "GTViewController/GTViewController/Resources/urlbutton@2x.png"
  install_resource "GTViewController/GTViewController/Resources/vline.png"
  install_resource "GTViewController/GTViewController/Classes/Nav Classes/GTPageMenuViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Nav Classes/GTViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Parsing Classes/GTAboutViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Parsing Classes/GTPage.xib"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS6.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS6@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS7.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS7@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8@3x.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "GTViewController/GTViewController/Resources/AbyssinicaSIL-R.ttf"
  install_resource "GTViewController/GTViewController/Resources/arrow.png"
  install_resource "GTViewController/GTViewController/Resources/arrow@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Buttonlines.png"
  install_resource "GTViewController/GTViewController/Resources/Buttonlines_large.png"
  install_resource "GTViewController/GTViewController/Resources/fiftytap.mp3"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_bot.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_E.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_NE.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_S.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_SE.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_SW.png"
  install_resource "GTViewController/GTViewController/Resources/grad_shad_top.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer@2x.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Shadow.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Shadow@2x.png"
  install_resource "GTViewController/GTViewController/Resources/GTInstructions_Hand_Pointer_Tap_Circle.png"
  install_resource "GTViewController/GTViewController/Resources/line.png"
  install_resource "GTViewController/GTViewController/Resources/NotoSansEthiopic-Bold.ttf"
  install_resource "GTViewController/GTViewController/Resources/NotoSansEthiopic-Regular.ttf"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Export.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Export@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Help.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Help@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Info.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Info@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Menu.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Menu@2x.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Switch.png"
  install_resource "GTViewController/GTViewController/Resources/Package_PopUpToolBar_Icon_Switch@2x.png"
  install_resource "GTViewController/GTViewController/Resources/URL_Button.png"
  install_resource "GTViewController/GTViewController/Resources/URL_Button@2x.png"
  install_resource "GTViewController/GTViewController/Resources/urlbutton.png"
  install_resource "GTViewController/GTViewController/Resources/urlbutton@2x.png"
  install_resource "GTViewController/GTViewController/Resources/vline.png"
  install_resource "GTViewController/GTViewController/Classes/Nav Classes/GTPageMenuViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Nav Classes/GTViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Parsing Classes/GTAboutViewController.xib"
  install_resource "GTViewController/GTViewController/Classes/Parsing Classes/GTPage.xib"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS6.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS6@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS7.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS7@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8@2x.png"
  install_resource "SSCWhatsAppActivity/SSCWhatsAppActivity/SSCWhatsAppIcon-iOS8@3x.png"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
