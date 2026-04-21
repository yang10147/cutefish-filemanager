/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "desktopview.h"
#include "dockdbusinterface.h"
#include "thumbnailer/thumbnailprovider.h"
#include "../desktopiconprovider.h"

#include <QQmlEngine>
#include <QQmlContext>

#include <QDebug>
#include <QGuiApplication>
#include <QScreen>

#include <KWindowSystem>
#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>

DesktopView::DesktopView(QScreen *screen, QQuickView *parent)
    : QQuickView(parent)
    , m_screen(screen)
{
    m_screenRect = m_screen->geometry();
    // Wayland: 必须在窗口 show() 前调用，全局启用 LayerShell 协议
    LayerShellQt::Shell::useLayerShell();
    this->setFlag(Qt::FramelessWindowHint);
    this->setColor(QColor(Qt::transparent));

    engine()->rootContext()->setContextProperty("desktopView", this);
    engine()->rootContext()->setContextProperty("Dock", DockDBusInterface::self());

    engine()->addImageProvider("thumbnailer", new ThumbnailProvider());
    engine()->addImageProvider("icontheme", new DesktopIconProvider());

    setTitle(tr("Desktop"));
    setScreen(m_screen);
    setResizeMode(QQuickView::SizeRootObjectToView);

    onGeometryChanged();
    onPrimaryScreenChanged(QGuiApplication::primaryScreen());

    // 主屏改变
    connect(qGuiApp, &QGuiApplication::primaryScreenChanged, this, &DesktopView::onPrimaryScreenChanged);

    connect(m_screen, &QScreen::virtualGeometryChanged, this, &DesktopView::onGeometryChanged);
    connect(m_screen, &QScreen::geometryChanged, this, &DesktopView::onGeometryChanged);

    // 配置 LayerShell：Background 层，四面锚定铺满全屏，不推开其他窗口
    if (auto *lsw = LayerShellQt::Window::get(this)) {
        lsw->setLayer(LayerShellQt::Window::LayerBackground);
        LayerShellQt::Window::Anchors anchors;
        anchors.setFlag(LayerShellQt::Window::AnchorTop);
        anchors.setFlag(LayerShellQt::Window::AnchorBottom);
        anchors.setFlag(LayerShellQt::Window::AnchorLeft);
        anchors.setFlag(LayerShellQt::Window::AnchorRight);
        lsw->setAnchors(anchors);
        lsw->setExclusiveZone(-1); // -1 = 不推开任何空间，其他窗口可以覆盖
        lsw->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityOnDemand);
    }
}

QRect DesktopView::screenRect()
{
    return m_screenRect;
}

void DesktopView::onPrimaryScreenChanged(QScreen *screen)
{
    bool isPrimaryScreen = m_screen->name() == screen->name();

    onGeometryChanged();

    setSource(isPrimaryScreen ? QStringLiteral("qrc:/qml/Desktop/Main.qml")
                              : QStringLiteral("qrc:/qml/Desktop/Wallpaper.qml"));
}

void DesktopView::onGeometryChanged()
{
    m_screenRect = m_screen->geometry();
    setGeometry(m_screenRect);
    emit screenRectChanged();
}
